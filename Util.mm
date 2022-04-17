#import <Foundation/NSError.h>
#import <cassert>

namespace util
{

   void
   GotHere( char const *File, int Line )
   {
      NSLog( @"Got Here: %s @ %d", File, Line );
   }

   void
   ReportErrors( NSError *Errors )
   {
      if ( Errors )
      {
         NSLog( @"%@", Errors );
         assert( not Errors );
      }
   }
}