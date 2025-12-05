function cleanup_function2pck()

try rmdir('*_test', 's'), catch, end
try delete('*.pck'), catch, end
