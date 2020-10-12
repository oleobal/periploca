# Post-mortem

Here I wrote my motivations and rationales for the choices I made,
along with an assessment of how they turned out.

Decentralized peer discovery (which I'll abbreviate PD) is an open problem,
so I knew from the start I would rely on a centralized service for locating
peers (as was suggested in the problem statement).

From that, the architecture was quite clear so I didn't spend any time on design
beyond a diagram.

Since this is a time-bounded exercise, I kept to basic features and included
very little validation.

## Server

I chose to implement the server in D; I am very very far from mastering the
language, but I feel reasonably productive in it and thought it might be
of interest to the examiner. I also went for a HTTP server, because that would
be the easiest to develop and debug (plenty of tools exist). In addition, I had
wanted to try out the Vibe.d web framework for some time.

I am happy with it, it is quite basic but does the job. I use it containerized behind a Traefik reverse proxy.

One weakness is that it cannot save peer identity on disk or in a database,
only in RAM. However, as peers register right before starting to listen, this
is not a big problem.

## Client

I considered implementing a WebRTC client. However:
 - I don't hate Javascript but I don't particularly like it either
 - I realized I would be reading a lot of documentation, and while that is part
   of our job, I wanted to make the exercise fun
 - I would have needed to address problems I wasn't interested in,
   such as NAT traversal

I therefore went for talking directly over a TCP connection, because it is the
kind of low-level I rarely have an excuse to play with in a professional
setting, and because I wanted to use netcat for testing the client before it was
finished.

I chose Python 3 for the client, primarily because everyone has that on their
machine.

I also decided to limit myself to two-people chat and leave the listen/connect
division apparent, neither things I would do were this an actual product:
I would probably have everyone listening in the background at all times, and
separate between simultaneous conversations in a high layer with
corresponding UI.

I had been curious about the new async features of Python 3.7, so I tried to use
them. I am not happy about the results, however. It might be the result of
inexperience, but I don't find my solution particularly elegant, nor asyncio
pleasant to work with. I don't spend all that much time programming parallel
applications, but when I do I tend to be partial to explicit threads and
well-defining shared data, because that makes the application easier to
understand and debug (at the cost of being wordier to program).

A particularly irritating thing to me is how I like to close my programs with
Ctrl+C (either KeyboardInterrupt or SIGINT in Python), and I couldn't find the
time to smooth things over before stopping work on this.

## Some considerations

### Limitations

> What are the limitations of this solution?
> Are there cases where your service will not work?

Beyond the UI, the main limitation I think of is the centralized peer discovery
service. There is however a simple solution if we adopt a federated model:

- We modify the server so that it can ask other PD servers for their info.
- We modify peer profiles to include their "home" server: instead of `olivier`,
  I register as `olivier@periploca.leobal.eu`

So I, `olivier@periploca.leobal.eu`, can ask to talk to
`gordon.freeman@blackmesa.us`. The PD server I am attached to fetches the info
for me, and our conversation can begin. (we could also modify the client for
this, but a cool effect of doing it server-side is that it gives servers a way
to say "we belong to the same community" depending on which server they trust.)

Then, if anybody can set up a server, this somewhat decentralizes peer discovery
(and also hosting costs) while allowing for a large network.

It is while thinking of this I realized I really was reimplementing DNS (it
could probably be done with a bunch of TXT records).
However I think it would have taken me more time to properly configure a DNS
server than to implement my own solution. (and would have been less fun!)

---

Obviously, a peer discovery server being down means all users registered there
can't use the service anymore.

The realistic case where my solution might not work is if filtering is imposed
on the network. However, since the clients may use any port and the PD server
answers over HTTP, it should be able to evade most enterprise networks.


### Scaling

> Does your system scale?
> Where is the bottleneck?
> How many users can it support?

Peer-to-peer by definition scales well, so no worries on that front.

The bottleneck is the centralized PD service. This is something else that can be
alleviated through federation.

I have not load-tested the server and obviously this depends on the underlying
resources, but given C10k was twenty years ago, I would expect a few thousand
users at a time not being a problem on my VPS which hosts `periploca.leobal.eu`.

### Security

> What is the attack surface on the system?
> How could you reduce it?

The current solution is vulnerable to man-in-the-middle attacks because it uses
no security at any point.

**Regarding peer discovery**
It is trivial to wrap the server into a TLS connection, but the client I wrote
is unable to handle HTTPS (although that is perfectly possible). In fact, I had
to disable Traefik's redirection from HTTP to HTTPS for this specific server.

**Regarding p2p chatting**
Here as well, the connection is plain TCP and would take no effort to intercept.
Just like with peer discovery, I deemed TLS wasn't a "basic feature" so I didn't
work on it.

---

Another problem is that anyone can register on a PD server, which is an obvious
attack vector. A simple solution would be:
 - On the server: 
  - When someone registers for the first time, ask for a public key
  - When they attempt to update their peer info, ask them to sign a random
    string with their corresponding private key.
 - On the client:
   - When establishing connection with someone, ask them to sign a random string
     with the private key that corresponds to their public key as registered on
     the PD server

### Compatibility

> which OS/browsers/systems is our service compatible with?

In theory, all of the ones Python 3 (..or netcat) runs on and that have a TCP/IP
network stack.

