## Periploca

A basic P2P chat with centralized peer discovery.

### Server

It is a HTTP server which accepts peer registries and answers with an address
when someone asks for a peer id. Come to think of it, it is more or less a DNS
server.

Written in D as I'd wanted to try the Vibe-d web framework.
Answers over HTTP for ease of debugging.

### Client

Written in Python 3 because people are likely to have that installed.

However, as I wanted to try out the new asyncio functions, Python 3.7 is
required.

The client has two modes, `listen` (where it waits for incoming connections)
and `connect` (where it connects to someone listening). In a real life scenario
you'd listen all the time in the background.

Python is not strictly needed, here's me connecting to a listening peer:
```
$ curl server/locate/myfriend | xargs -o ncat
```

### Why the name

The Samba method of naming projects:

"Peer to peer chat" -> "PPC" -> `grep -i '^p.*p.*c' /usr/share/dict/words`