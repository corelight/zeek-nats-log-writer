# @TEST-REQUIRES: have-nats
# @TEST-EXEC: nats-cleanup
# @TEST-EXEC: zeek -r $TRACES/dns-http-https.pcap %INPUT
# @TEST-EXEC: echo "== conn-a (filter override -> EPOCH) ==" >> ts.out && nats subscribe 'test-sensor.logs.conn-a' --all -r --wait=$SUBSCRIBE_WAIT | jq -c '.ts' | sort >> ts.out
# @TEST-EXEC: echo "== conn-b (filter override -> ISO8601) ==" >> ts.out && nats subscribe 'test-sensor.logs.conn-b' --all -r --wait=$SUBSCRIBE_WAIT | jq -c '.ts' | sort >> ts.out
# @TEST-EXEC: btest-diff ts.out
#
# @TEST-DOC: Two overlapping filters on the same log stream each carry their own json_timestamps and format independently. The timestamp format is a per-writer property, not a per-stream one: there is no cross-filter resolution. Both filters here also override a third global default (TS_MILLIS), confirming the override is applied per filter.

@if ( Version::number >= 70100 )
@load policy/protocols/conn/disable-unknown-ip-proto-support
@endif

redef Log::default_writer = Log::WRITER_NATS;

# A single wildcard-subject stream (reset by nats-cleanup) holds both filters'
# records; per-path narrow-subject streams would leak past nats-cleanup and
# poison later tests with overlapping-subject errors.
redef LogNATS::stream_name_template = "test-sensor-logs";
redef LogNATS::publish_subject_template = "test-sensor.logs.{path}";
redef LogNATS::stream_subject_template = "test-sensor.logs.*";
# Global default is TS_MILLIS; neither overlapping filter below should emit it.
redef LogNATS::json_timestamps = JSON::TS_MILLIS;

event zeek_init()
	{
	Log::disable_stream(PacketFilter::LOG);
	Log::disable_stream(DNS::LOG);
	Log::disable_stream(HTTP::LOG);
	Log::disable_stream(SSL::LOG);

	Log::remove_default_filter(Conn::LOG);
	Log::add_filter(Conn::LOG, Log::Filter($name="conn-a", $path="conn-a",
	    $config=table(["json_timestamps"] = "JSON::TS_EPOCH")));
	Log::add_filter(Conn::LOG, Log::Filter($name="conn-b", $path="conn-b",
	    $config=table(["json_timestamps"] = "JSON::TS_ISO8601")));
	}
