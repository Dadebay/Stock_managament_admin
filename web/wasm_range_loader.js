// The network path to the production server intermittently closes large HTTP
// responses. Fetch the Dart WASM entrypoint in small byte ranges so every
// response remains below that limit, then hand Flutter one complete Response.
(() => {
  const chunkSize = 64 * 1024;
  const nativeFetch = window.fetch.bind(window);

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

  window.fetch = async (input, init) => {
    if (!isEntrypoint(input)) return nativeFetch(input, init);

    const existingHeaders = new Headers(init?.headers || (input instanceof Request ? input.headers : undefined));
    if (existingHeaders.has('Range')) return nativeFetch(input, init);

    const url = input instanceof Request ? input.url : input;
    const request = { ...init, headers: rangeHeaders(existingHeaders, 0, chunkSize - 1) };
    const first = await nativeFetch(url, request);
    if (first.status !== 206) return first;

    const total = totalSize(first);
    const chunks = [await first.arrayBuffer()];
    for (let start = chunkSize; start < total; start += chunkSize) {
      const end = Math.min(start + chunkSize - 1, total - 1);
      const response = await nativeFetch(url, { ...init, headers: rangeHeaders(existingHeaders, start, end) });
      if (response.status !== 206) throw new Error(`WASM range request failed (${response.status}).`);
      chunks.push(await response.arrayBuffer());
    }

    return new Response(new Blob(chunks, { type: 'application/wasm' }), {
      status: 200,
      statusText: 'OK',
      headers: { 'Content-Type': 'application/wasm' },
    });
  };
})();
