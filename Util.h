#import <Foundation/NSError.h>

#define GOT_HERE()                         \
   do {                                    \
      util::GotHere( __FILE__, __LINE__ ); \
   } while ( 0 )

namespace util {
   void GotHere( char const *File, int Line );

   void ReportErrors( NSError *Errors );

} // namespace util