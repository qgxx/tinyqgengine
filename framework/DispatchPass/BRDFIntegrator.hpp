#pragma once
#include "IDispatchPass.hpp"

namespace qg {
    class BRDFIntegrator : implements IDispatchPass
    {
    public:
        ~BRDFIntegrator() = default; 
        void Dispatch(void) final;
    };
}