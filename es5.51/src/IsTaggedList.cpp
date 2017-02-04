#include "is_tagged_list.h"
#include "bool.h"
#include "is.h"
#include <iostream>
using namespace std;

IsTaggedList::IsTaggedList(Symbol* tag)
{
    this->tag = tag;
}

Value* IsTaggedList::execute(std::vector<Value*> elements)
{
    cout << "IsTaggedList" << endl;
    cout << elements.at(0)->toString() << endl;
    if (is_tagged_list(elements.at(0), new Symbol("quote"))) {
        return new Bool(true);
    }
    return new Bool(false);
}

std::string IsTaggedList::toString()
{
    return std::string("Operation-IsTaggedList");
}
