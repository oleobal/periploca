import std.datetime;

import vibe.d;

import util;

struct PeerInfo
{
	string address;
	int port;
	SysTime lastUpdate;
}

PeerInfo[string] peers;


void registerPeer(HTTPServerRequest req, HTTPServerResponse res)
{
	enforceHTTP(("peerid" in req.form && "address" in req.form && "port" in req.form),
	  HTTPStatus.badRequest, "Fields peerid, address, & port are required.");
	
	peers[req.form["peerid"]] = PeerInfo(req.form["address"], req.form["port"].to!int, Clock.currTime());
	res.writeBody("%s set to %s:%s\n".format(req.form["peerid"], req.form["address"], req.form["port"]));
}

void locatePeer(HTTPServerRequest req, HTTPServerResponse res)
{
	auto peerId = req.params["peerid"];
	if (peerId in peers)
	{
		res.writeBody(peers[peerId].address~"\n"~peers[peerId].port.to!string);
	}
	else
	{
		res.statusCode = 404; // 204 "No content"
		res.writeBody(peerId~" is unknown\n");
	}
}

void listPeers(HTTPServerRequest req, HTTPServerResponse res)
{
	auto peerList="peers: "~(peers.length==0 ? "{}\n":"\n");
	
	
	// it uses peerIds as keys, which might yield incorrect YAML
	// .. but I never said it was YAML
	foreach(peer; peers.byKeyValue())
	{
		peerList~=(
		"  %s:\n"~
		"    address: '%s'\n"~
		"    port: %s\n"~
		"    lastUpdate: '%s'\n")
		.format(peer.key, peer.value.address, peer.value.port, peer.value.lastUpdate.toISOExtString());
	}
	
	
	res.writeBody(peerList);
}

void index(HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody(
		/+ 
		 + the use of __TIMESTAMP__ precludes reproducible builds, but the alternative
		 + is version numbers and that would be silly on a 100-line project
		 +/
		"Periploca-server built "~__TIMESTAMP__~"\n\n"~
		`
		Paths:
		  /                this page
		  /register        register a new peer. POST fields: peerid, address, port
		  /locate/<peerid> locate an existing peer, 404 if the peer is not found
		  /list            list peers
		`.trimIndent()
	);
}

void main()
{
	auto router = new URLRouter;
	router.post("/register", &registerPeer);
	router.get("/locate/:peerid", &locatePeer);
	router.get("/list", &listPeers);
	router.get("/", &index);

	auto settings = new HTTPServerSettings;
	settings.port = 80;
	
	readOption("port", &settings.port, "Port to listen on");
	
	listenHTTP(settings, router);
	runApplication();
}