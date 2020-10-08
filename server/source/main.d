import std.datetime;

import vibe.d;

import util;

struct PeerInfo
{
	string address;
	SysTime lastUpdate;
}

PeerInfo[string] peers;


void registerPeer(HTTPServerRequest req, HTTPServerResponse res)
{
	enforceHTTP(("peerid" in req.form && "address" in req.form),
	  HTTPStatus.badRequest, "Fields peerid & address are required.");
	
	peers[req.form["peerid"]] = PeerInfo(req.form["address"], Clock.currTime());
	res.writeBody(req.form["peerid"]~" set to "~req.form["address"]~"\n");
}

void locatePeer(HTTPServerRequest req, HTTPServerResponse res)
{
	auto peerId = req.params["peerid"];
	if (peerId in peers)
	{
		res.writeBody(peers[peerId].address);
	}
	else
	{
		res.statusCode = 404; // 204 "No content"
		res.writeBody("peerid "~peerId~" is unknown\n");
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
		"    lastUpdate: '%s'\n")
		.format(peer.key, peer.value.address, peer.value.lastUpdate);
	}
	
	
	res.writeBody(peerList);
}

void index(HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody(
		"Periploca-server built "~__TIMESTAMP__~"\n\n"~
		`
		Paths:
		  /                this page
		  /register        register a new peer. POST fields: peerid, address
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
	settings.port = 8080;
	listenHTTP(settings, router);
	runApplication();
}