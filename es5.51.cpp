#include <string>
#include <iostream>
using namespace std;

typedef char* Symbol;


class Value
{
    public:
        virtual std::string toString() = 0;
};

class SchemeInteger : public Value
{
    private:
        int contents;
    public:
        SchemeInteger(int contents);
        virtual std::string toString();
};

SchemeInteger::SchemeInteger(int contents)
{
    this->contents = contents;
}

std::string SchemeInteger::toString()
{
    return std::to_string(this->contents);
}

class Cons
{
    private:
        Value *car_ptr;
        Value *cdr_ptr;

    public:
        Cons(Value *car_ptr, Value *cdr_ptr);
        Value* car();
        Value* cdr();
};

Cons::Cons(Value *car_ptr, Value *cdr_ptr)
{
    this->car_ptr = car_ptr;
    this->cdr_ptr = cdr_ptr;
}

Value* Cons::car()
{
    return this->car_ptr;
}

Value* Cons::cdr()
{
    return this->cdr_ptr;
}

int main() {
    Cons* cell = new Cons(new SchemeInteger(42), new SchemeInteger(43));
    Value* i = cell->car();
    cout << i->toString() << endl;
    return 0;
}
