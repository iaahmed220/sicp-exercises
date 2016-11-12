#include "branch.h"
#include <iostream>
using namespace std;

Branch::Branch(Register* test, Machine* machine, int labelIndex)
{
    this->test = test;
    this->machine = machine;
    this->labelIndex = labelIndex;
}

void Branch::execute()
{
    Value* result = this->test->get();
    bool do_we_branch = result->toString() == "#t";
    cout << "Branch(" << this->labelIndex << "): " << (do_we_branch ? "#t" : "#f") << endl;
    if (do_we_branch) {
        this->machine->forceInstruction(this->labelIndex);
    } else {
        this->machine->nextInstruction();
    }
}
