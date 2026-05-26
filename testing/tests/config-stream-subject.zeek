# @TEST-REQUIRES: have-nats
# @TEST-EXEC: nats stream rm -f test-sensor-logs-conn || true
# @TEST-EXEC: zeek -r $TRACES/dns-http-https.pcap %INPUT
# @TEST-EXEC: nats stream info test-sensor-logs-conn -j | jq -r '.config.subjects[]' > stream-subject.out
# @TEST-EXEC: btest-diff stream-subject.out
#
# @TEST-DOC: Setting stream_subject_template via per-filter config should override the global.

@if ( Version::number >= 70100 )
@load policy/protocols/conn/disable-unknown-ip-proto-support
@endif

redef Log::default_writer=Log::WRITER_NATS;

redef LogNATS::stream_name_template = "test-sensor-logs-{path}";
redef LogNATS::publish_subject_template = "test-sensor.logs.{path}";
redef LogNATS::stream_subject_template = "test-sensor.logs.{path}";

event zeek_init()
	{
	Log::disable_stream(PacketFilter::LOG);
	Log::disable_stream(DNS::LOG);
	Log::disable_stream(HTTP::LOG);
	Log::disable_stream(SSL::LOG);

	local f = Log::get_filter(Conn::LOG, "default");
	f$config = table(
		["stream_subject_template"] = "custom-conn-subject"
	);
	Log::remove_filter(Conn::LOG, "default");
	Log::add_filter(Conn::LOG, f);
	}
