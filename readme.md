## Periploca

A basic P2P chat with centralized peer discovery.

### Server

It is a HTTP server which accepts peer registries and answers with an address
when someone asks for a peer id. Come to think of it, it is more or less a DNS
server.

Written in D as I'd wanted to try the Vibe-d web framework.
Answers over HTTP for ease of debugging.

### Client

(to be done)

### Why the name

The Samba method of naming projects:

"Peer to peer chat" -> "PPC" -> `grep -i '^p.*p.*c' /usr/share/dict/words`