#include "../src/apply_primitive_procedure.h"
#include "../src/cons.h"
#include "../src/integer.h"
#include "../src/string.h"
#include "../src/primitive_plus.h"
#include <gtest/gtest.h>
 
TEST(ApplyPrimitiveProcedureTest, Plus) { 
    ApplyPrimitiveProcedure* operation = new ApplyPrimitiveProcedure();

    ASSERT_EQ(
        Integer(3),
        *operation->execute({
            Cons::from_vector({ new String("+"), new PrimitivePlus() }),
            Cons::from_vector({ new Integer(1), new Integer(2) })
        })
    );
}
