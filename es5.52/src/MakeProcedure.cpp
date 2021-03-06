#include "make_procedure.h"
#include "cons.h"
#include "symbol.h"
#include "assertion.h"
#include <iostream>
using namespace std;

Value* MakeProcedure::execute(std::vector<Value*> elements)
{
    assert_elements(elements, 3);
    return Cons::from_vector({ new Symbol("procedure"), elements.at(0), elements.at(1), elements.at(2) });
}

std::string MakeProcedure::to_string()
{
    return std::string("Operation-MakeProcedure");
}

