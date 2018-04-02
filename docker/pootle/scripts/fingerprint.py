############
# Calculate the fingerprint of a catalog
############

#### These are the relevant C++ methods
# uint32
# CatKey::HashFun(const char* s, int startValue) {
#   unsigned long h = startValue;
#   for ( ; *s; ++s)
#       h = 5 * h + *s;
# 
#   // Add 1 to differenciate ("ab","cd","ef") from ("abcd","e","f")
#   h = 5 * h + 1;
# 
#   return size_t(h);
# }

def hashfun(string, startValue):
    h = startValue
    array = string.decode('string_escape')
    
    for byte in array:
        value = ord(byte)
        if value > 127:
            value -= 256
        #print ('%s: %i' % (byte, ord(byte)))
        h = 5 * h + value
        h &= 0xFFFFFFFF
    
    # Add 1
    h = 5 * h + 1
    h &= 0xFFFFFFFF
    
    return h

# uint32
# BHashMapCatalog::ComputeFingerprint() const
# {
#   uint32 checksum = 0;
# 
#   int32 hash;
#   CatMap::Iterator iter = fCatMap.GetIterator();
#   CatMap::Entry entry;
#   while (iter.HasNext())
#   {
#       entry = iter.Next();
#       hash = B_HOST_TO_LENDIAN_INT32(entry.key.fHashVal);
#       checksum += hash;
#   }
#   return checksum;
# }

# CatKey::CatKey(const char *str, const char *ctx, const char *cmt)
#   (...)
# {
#   fHashVal = HashFun(fString.String(),0);
#   fHashVal = HashFun(fContext.String(),fHashVal);
#   fHashVal = HashFun(fComment.String(),fHashVal);
# }


def computefingerprint(catalogvalues):
    fingerprint = 0
    for string, context, comment, translated in catalogvalues:
        stringhash = hashfun(string, 0)
        stringhash &= 0xFFFFFFFF
        stringhash = hashfun(context, stringhash)
        stringhash &= 0xFFFFFFFF
        stringhash = hashfun(comment, stringhash)
        stringhash &= 0xFFFFFFFF
        #print("Hash for string, context, comment with string %s: %s" % (string, stringhash))
        fingerprint += stringhash
        fingerprint &= 0xFFFFFFFF
        
    return fingerprint

