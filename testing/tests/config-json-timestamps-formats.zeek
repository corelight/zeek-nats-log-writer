# @TEST-REQUIRES: have-nats
#
# @TEST-EXEC: nats-cleanup && zeek -r $TRACES/dns-http-https.pcap %INPUT -e 'redef LogNATS::json_timestamps=JSON::TS_EPOCH;'           && echo "== TS_EPOCH =="           >> ts.out && nats subscribe 'test-sensor.logs.*' --all -r --wait=$SUBSCRIBE_WAIT | jq -c '.ts' | sort >> ts.out
# @TEST-EXEC: nats-cleanup && zeek -r $TRACES/dns-http-https.pcap %INPUT -e 'redef LogNATS::json_timestamps=JSON::TS_MILLIS;'          && echo "== TS_MILLIS =="          >> ts.out && nats subscribe 'test-sensor.logs.*' --all -r --wait=$SUBSCRIBE_WAIT | jq -c '.ts' | sort >> ts.out
# @TEST-EXEC: nats-cleanup && zeek -r $TRACES/dns-http-https.pcap %INPUT -e 'redef LogNATS::json_timestamps=JSON::TS_MILLIS_UNSIGNED;' && echo "== TS_MILLIS_UNSIGNED ==" >> ts.out && nats subscribe 'test-sensor.logs.*' --all -r --wait=$SUBSCRIBE_WAIT | jq -c '.ts' | sort >> ts.out
# @TEST-EXEC: nats-cleanup && zeek -r $TRACES/dns-http-https.pcap %INPUT -e 'redef LogNATS::json_timestamps=JSON::TS_ISO8601;'         && echo "== TS_ISO8601 =="         >> ts.out && nats subscribe 'test-sensor.logs.*' --all -r --wait=$SUBSCRIBE_WAIT | jq -c '.ts' | sort >> ts.out
# @TEST-EXEC: btest-diff ts.out
#
# @TEST-DOC: LogNATS::json_timestamps renders ts in the selected format for each of the four supported values, set globally. TS_MILLIS and TS_MILLIS_UNSIGNED render identically here (both emit integer milliseconds); they only diverge for pre-1970 (negative) timestamps, which this pcap does not contain.

@if ( Version::number >= 70100 )
@load policy/protocols/conn/disable-unknown-ip-proto-support
@endif

redef LogNATS::publish_subject_template = "test-sensor.logs.{path}";
redef LogNATS::stream_name_template = "test-sensor-logs";
redef LogNATS::stream_subject_template = "test-sensor.logs.*";

redef Log::default_writer = Log::WRITER_NATS;

# Only conn is kept so the ts.out captures a small, stable set of records.
event zeek_init()
	{
	Log::disable_stream(PacketFilter::LOG);
	Log::disable_stream(DNS::LOG);
	Log::disable_stream(HTTP::LOG);
	Log::disable_stream(SSL::LOG);
	}
