# @TEST-EXEC: zeek -NN Zeek::NATS | sed -e 's/version.*)/version)/g' >output
# @TEST-EXEC: btest-diff output
