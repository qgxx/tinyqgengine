#pragma once
#include "Ability.hpp"

namespace qg {
    template<typename T>
    Ability Animatable
    {
    public:
        virtual ~Animatable() = default;
        typedef const T ParamType;
        virtual void Update(ParamType param) = 0;
    };
}