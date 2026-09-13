// The network path to the production server intermittently closes large HTTP
// responses. Fetch the Dart WASM entrypoint in small byte ranges so every
// response remains below that limit, then hand Flutter one complete Response.
//
// Ranges are not reliable either on every network: a chunk can arrive
// truncated (ERR_CONTENT_LENGTH_MISMATCH) or the connection can be reset
// mid-body (ERR_CONNECTION_RESET). A single bad chunk used to abort the whole
// load, leaving a blank page. Every chunk is therefore retried, and a short
// body is treated as a failure even when fetch() itself resolves.
(() => {
  const chunkSize = 64 * 1024;
  const maxAttempts = 6;
  const retryDelayMs = (attempt) => Math.min(2000, 150 * 2 ** (attempt - 1));

  const nativeFetch = window.fetch.bind(window);
  const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

  const isEntrypoint = (input) => {
    const url = input instanceof Request ? input.url : String(input);
    return new URL(url, window.location.href).pathname.endsWith('/main.dart.wasm');
  };

  const rangeHeaders = (headers, start, end) => {
    const result = new Headers(headers);
    result.set('Range', `bytes=${start}-${end}`);
    return result;
  };

  const totalSize = (response) => {
    const match = /^bytes \d+-\d+\/(\d+)$/.exec(response.headers.get('Content-Range') || '');
    if (!match) throw new Error('The server did not return a valid WASM byte range.');
    return Number(match[1]);
  };

  // Resolves to {response, buffer}. `buffer` is null when the server answered
  // with something other than 206, which the caller handles as "no range
  // support" rather than as an error.
  const fetchRange = async (url, init, headers, start, end) => {
    const expected = end - start + 1;
    let lastError;

    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        const response = await nativeFetch(url, {
          ...init,
          headers: rangeHeaders(headers, start, end),
        });
        if (response.status !== 206) return { response, buffer: null };

        const buffer = await response.arrayBuffer();
        // A truncated body can still surface as a resolved fetch, so the
        // length is what decides whether the chunk is usable.
        if (buffer.byteLength !== expected) {
          throw new Error(`got ${buffer.byteLength} of ${expected} bytes`);
        }
        return { response, buffer };
      } catch (error) {
        lastError = error;
        if (attempt < maxAttempts) await sleep(retryDelayMs(attempt));
      }
    }

    throw new Error(
      `WASM byte range ${start}-${end} failed after ${maxAttempts} attempts: ${lastError}`,
    );
  };

  window.fetch = async (input, init) => {
    if (!isEntrypoint(input)) return nativeFetch(input, init);

    const existingHeaders = new Headers(init?.headers || (input instanceof Request ? input.headers : undefined));
    if (existingHeaders.has('Range')) return nativeFetch(input, init);

    const url = input instanceof Request ? input.url : input;
    const first = await fetchRange(url, init, existingHeaders, 0, chunkSize - 1);
    if (first.buffer === null) return first.response;

    const total = totalSize(first.response);
    const chunks = [first.buffer];
    for (let start = chunkSize; start < total; start += chunkSize) {
      const end = Math.min(start + chunkSize - 1, total - 1);
      const chunk = await fetchRange(url, init, existingHeaders, start, end);
      if (chunk.buffer === null) {
        throw new Error(`WASM range request failed (${chunk.response.status}).`);
      }
      chunks.push(chunk.buffer);
    }

    return new Response(new Blob(chunks, { type: 'application/wasm' }), {
      status: 200,
      statusText: 'OK',
      headers: { 'Content-Type': 'application/wasm' },
    });
  };
})();
