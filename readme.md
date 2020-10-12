# Periploca

A basic P2P chat with centralized peer discovery.

[Some after-the fact considerations here](./post-mortem.md)

## Server

It is a HTTP server which:
  - accepts peer registries (`/register`)
  - answers with an address and port when someone asks for a peer id (`/locate`)

Come to think of it, it is more or less a DNS
server.

I have a docker image [here](https://hub.docker.com/r/oleobal/periploca-server),
and a running instance [there](https://periploca.leobal.eu).

## Client

Written in Python 3 because people are likely to have that installed.

However, as I wanted to try out the new asyncio functions, Python 3.7 is
required.

The client has two modes, `listen` (where it waits for incoming connections)
and `connect` (where it connects to someone listening). In a real life scenario
you'd listen all the time in the background.

Python is not strictly needed, here's me listening:
```
curl -X POST "periploca.leobal.eu/register" \
	--data "peerid=olivier" \
	--data "address=192.168.1.76" \
	--data "port=59346" \
&& ncat -l 59346
```

And here is me connecting to a peer:
```
curl periploca.leobal.eu/locate/myfriend | xargs -o ncat
```

## Why the name

The Samba method of naming projects:

"Peer to peer chat" -> "PPC" -> `grep -i '^p.*p.*c' /usr/share/dict/words`