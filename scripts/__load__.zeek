module NATS;

export {
	type StreamStorage: enum {
		FILE,
		MEMORY,
	};

	global url: string = "nats://localhost:4222" &redef;
	global stream_name: string = "sensor-logs" &redef;
	global subject_prefix: string = "sensor.logs" &redef;
	global stream_storage: StreamStorage = FILE &redef;

	global include_unset_fields: bool = F &redef;
}
