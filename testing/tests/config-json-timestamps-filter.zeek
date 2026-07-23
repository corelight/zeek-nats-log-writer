# @TEST-REQUIRES: have-nats
# @TEST-EXEC: nats-cleanup
# @TEST-EXEC: zeek -r $TRACES/dns-http-https.pcap %INPUT
# @TEST-EXEC: echo "== conn (per-filter override -> ISO8601) ==" >> ts.out && nats subscribe 'test-sensor.logs.conn' --all -r --wait=$SUBSCRIBE_WAIT | jq -c '.ts' | sort >> ts.out
# @TEST-EXEC: echo "== dns (inherits global default -> EPOCH) =="  >> ts.out && nats subscribe 'test-sensor.logs.dns'  --all -r --wait=$SUBSCRIBE_WAIT | jq -c '.ts' | sort >> ts.out
# @TEST-EXEC: btest-diff ts.out
#
# @TEST-DOC: A per-filter $config["json_timestamps"] overrides the global LogNATS::json_timestamps for that filter's path only. Here the global default is TS_EPOCH; the conn filter overrides to TS_ISO8601 while the dns filter inherits the epoch default.

@if ( Version::number >= 70100 )
@load policy/protocols/conn/disable-unknown-ip-proto-support
@endif

redef Log::default_writer = Log::WRITER_NATS;

# A single wildcard-subject stream (reset by nats-cleanup) holds both paths'
# records; per-path narrow-subject streams would leak past nats-cleanup and
# poison later tests with overlapping-subject errors.
redef LogNATS::stream_name_template = "test-sensor-logs";
redef LogNATS::publish_subject_template = "test-sensor.logs.{path}";
redef LogNATS::stream_subject_template = "test-sensor.logs.*";
# Global default deliberately left at the plugin default (JSON::TS_EPOCH) so the
# per-filter override below is exercised against a *different* global format.

event zeek_init()
	{
	Log::disable_stream(PacketFilter::LOG);
	Log::disable_stream(HTTP::LOG);
	Log::disable_stream(SSL::LOG);

	local f = Log::get_filter(Conn::LOG, "default");
	f$config = table(
		["json_timestamps"] = "JSON::TS_ISO8601"
	);
	Log::remove_filter(Conn::LOG, "default");
	Log::add_filter(Conn::LOG, f);
	}
