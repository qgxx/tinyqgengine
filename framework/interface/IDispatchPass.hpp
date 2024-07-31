#pragma once
#include <iostream>
#include "Interface.hpp"

namespace qg {
    Interface IDispatchPass
    {
    public:
        IDispatchPass() = default;
        virtual ~IDispatchPass() {};

        virtual void Dispatch(void) = 0;
    };
}