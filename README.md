# Streaming ed25519 signature checking
Streaming implementation of http://www.dlbeer.co.nz/oss/c25519.html and some tests to validate streaming implementation against reference.
Only signature verification is streamed, signing requires traversing input twice and it's not obvious if it's possible to avoid it.
