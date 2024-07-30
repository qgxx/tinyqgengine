#include <cstddef>
#include <cstdint>
#include <list>
#include <memory>
#include "IAllocator.hpp"

namespace qg {
    class StackAllocator : implements IAllocator
    {
    public:
        StackAllocator();
        StackAllocator(size_t page_size, size_t alignment);
        ~StackAllocator();
        // disable copy & assignment
        StackAllocator(const StackAllocator& clone) = delete;
        StackAllocator &operator=(const StackAllocator &rhs) = delete;

        // alloc and free blocks
        void* Allocate(size_t size);
        void  Free(void* p);
        void  FreeAll();

    protected:
        std::list<uint8_t*> m_pPages;
        std::list<std::shared_ptr<void>> m_pAllocatedPointers;
        off_t m_StackTop;
        size_t m_MaxSize;
    };
}