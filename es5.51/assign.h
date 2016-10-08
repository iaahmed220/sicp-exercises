#ifndef ASSIGN_H
#define ASSIGN_H
#include <vector>
#include "operation.h"
#include "instruction.h"
#include "machine.h"
#include "value.h"
#include "register.h"

class Assign: public Instruction
{
    private:
        // `register` is a reserved keyword
        Register* register_;
        Operation* operation;
        std::vector<Value*> operands;
        Machine* machine;
    public:
        Assign(Register* register_, Operation* operation, std::vector<Value*> operands, Machine *machine);
        virtual void execute();
};

#endif
