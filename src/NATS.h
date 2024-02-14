#pragma once

#include <nats.h>
#include <memory>
#include <vector>

#include "zeek/Desc.h"
#include "zeek/logging/WriterBackend.h"
#include "zeek/threading/formatters/JSON.h"

using namespace zeek::logging;

namespace zeek::plugin::Zeek_NATS::detail {

struct NATSWriterStats {
    zeek_uint_t dropped_writes = 0;
};

class NATSWriter : public WriterBackend {
public:
    explicit NATSWriter(WriterFrontend* frontend);
    ~NATSWriter() override;

    static WriterBackend* Instantiate(WriterFrontend* frontend) { return new NATSWriter(frontend); }


protected:
    bool DoInit(const WriterInfo& info, int arg_num_fields, const threading::Field* const* arg_fields) override;
    bool DoWrite(int num_fields, const threading::Field* const* fields, threading::Value** vals) override;
    bool DoSetBuf(bool enabled) override { return true; }
    bool DoRotate(const char* rotated_path, double open, double close, bool terminating) override { return true; }
    bool DoFlush(double network_time) override;
    bool DoFinish(double network_time) override;
    bool DoHeartbeat(double network_time, double current_time);

    // Try connect and setup the stream.
    bool Connect();

private:
    natsConnection* conn = nullptr;
    natsOptions* opts = nullptr;
    jsCtx* js = nullptr;
    jsOptions jsOpts;
    std::string url;
    std::string stream_name;
    std::string subject;
    std::string subject_prefix;
    std::string stream_subject;
    std::vector<const char*> stream_subjects;
    zeek_uint_t stream_storage;

    NATSWriterStats writer_stats;

    std::unique_ptr<zeek::threading::formatter::JSON> formatter;
    zeek::ODesc desc;
    bool include_unset_fields;
};
} // namespace zeek::plugin::Zeek_NATS::detail
