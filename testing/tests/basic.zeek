# @TEST-REQUIRES: have-nats
# @TEST-EXEC: nats stream rm sensor-logs -f || true
# @TEST-EXEC: zeek -r $TRACES/dns-http-https.pcap %INPUT
# @TEST-EXEC: nats subscribe 'sensor.logs.*' -r --all --wait=5us | sort > sensor-logs.jsonl
# @TEST-EXEC: btest-diff sensor-logs.jsonl

redef Log::default_writer=Log::WRITER_NATS;

event zeek_init()
	{
	Log::disable_stream(PacketFilter::LOG);
	}
