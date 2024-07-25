#pragma once
#include "Ability.hpp"

namespace qg {
    template<typename T>
    Ability Animatable
    {
        typedef const T ParamType;
        virtual void Update(ParamType param) = 0;
    };
}