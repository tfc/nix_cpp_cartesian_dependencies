#include <boost/lexical_cast.hpp>

#include <Poco/Environment.h>

#include <iostream>

#if defined(__clang__)
#define CC "clang++"
#elif defined (__GNUC__)
#define CC "g++"
#else
#define CC "<unknown compiler>"
#endif

int main() {
  std::cout << "Hello World!\n"
    << "Compiler: " << CC << " " << __VERSION__ << '\n'
    << "Boost: " << (BOOST_VERSION / 100000) << '.'
                 << (BOOST_VERSION / 100 % 1000) << '.'
                 << (BOOST_VERSION % 100) << '\n'
    << "POCO: " << (Poco::Environment::libraryVersion() >> 24) << '.'
                << (Poco::Environment::libraryVersion() >> 16 & 0xff) << '.'
                << (Poco::Environment::libraryVersion() >> 8 & 0xff)
                << '\n';
}
