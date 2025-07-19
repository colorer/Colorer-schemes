#include <iostream>
 
char array1[] = "Foo" "bar";
// same as
char array2[] = { 'F', 'o', 'o', 'b', 'a', 'r', '\0' };
 
const char* s1 = R"foo(
Hello
  World
)foo";
// same as
const char* s2 = "\nHello\n  World\n";
// same as
const char* s3 = "\n"
                 "Hello\n"
                 "  World\n";
 
const wchar_t* s4 = L"ABC" L"DEF"; // ok, same as
const wchar_t* s5 = L"ABCDEF";
const char32_t* s6 = U"GHI" "JKL"; // ok, same as
const char32_t* s7 = U"GHIJKL";
const char16_t* s9 = "MN" u"OP" "QR"; // ok, same as
const char16_t* sA = u"MNOPQR";
 
// const auto* sB = u"Mixed" U"Types";
        // before C++23 may or may not be supported by
        // the implementation; ill-formed since C++23
 
const wchar_t* sC = LR"--(STUV)--"; // ok, raw string literal
 

// OK: contains one backslash,
// equivalent to "\\"
const char* r1 = R"(\)";
 
// OK: contains four \n pairs,
// equivalent to "\\n\\n\\n\\n"
const char* r2 = R"(\n\n\n\n)";
 
// OK: contains one close-parenthesis, two double-quotes and one open-parenthesis,
// equivalent to ")\"\"("
const char* r3 = R"-()""()-";
 
// OK: equivalent to "\n)\\\na\"\"\n"
const char* r4 =R"a(
)\
a""
)a";
 
// OK: equivalent to "x = \"\"\\y\"\""
const char* r5 = R"(x = ""\y"")";
 
// R"<<(-_-)>>"; // Error: begin and end delimiters do not match
const char* r6 = R"<<(-_-)>>";

// R"-()-"-()-"; // Error: )-" appears in the middle and terminates the literal

int main()
{
    std::cout << array1 << ' ' << array2 << '\n'
              << s1 << s2 << s3 << std::endl;
    std::wcout << s4 << ' ' << s5 << ' ' << sC
               << std::endl;