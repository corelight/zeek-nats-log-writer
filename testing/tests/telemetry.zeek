# @TEST-REQUIRES: have-nats
# @TEST-EXEC: nats-cleanup
# @TEST-EXEC: zeek -r $TRACES/wikipedia.trace %INPUT > out
# @TEST-EXEC: btest-diff out

@if ( Version::number >= 70100 )
@load policy/protocols/conn/disable-unknown-ip-proto-support
@endif

@if ( Version::number >= 80100 )
@load policy/protocols/dns/disable-opcode-log-fields
@endif

redef Log::default_writer = Log::WRITER_NATS;

redef LogNATS::stream_name_template = "test-sensor-logs-{path}";
redef LogNATS::publish_subject_template = "test-sensor.logs.{path}";
redef LogNATS::stream_subject_template = "test-sensor.logs.{path}";

event zeek_init()
	{
	Log::disable_stream(PacketFilter::LOG);
	}

event Pcap::file_done(path: string)
	{
@if ( Version::number >= 80100 )
	Log::flush_all();
@else
	Log::flush(Conn::LOG);
	Log::flush(HTTP::LOG);
	Log::flush(DNS::LOG);
@endif
	}

event zeek_done()
	{
	# Give the log writer threads a bit of time to process all the acks
	# and update the metrics.
	sleep(50msec);

	local metrics = Telemetry::collect_metrics("zeek_nats_log_writer_backend*", "*");
	for ( _, m in metrics )
		print m$opts$name, m$label_values, m$value;
	}
