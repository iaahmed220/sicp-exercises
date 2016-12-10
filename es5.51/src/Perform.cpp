#include "perform.h"
#include <iostream>
using namespace std;

Perform::Perform(Operation* operation, std::vector<Value*> operands, MachineFeedback* machine)
{
    this->operation = operation;
    this->operands = operands;
    this->machine_feedback = machine;
}

void Perform::execute()
{
    cout << "Perform: " << this->operation->toString() << endl;
    cout << "operands length: " << this->operands.size() << endl;
    auto elements = this->fetch_operands(this->operands);
    this->operation->execute(elements);
    this->machine_feedback->nextInstruction();
}