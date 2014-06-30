#pragma once
#ifndef ___lang_array___
#define ___lang_array___

#ifdef __OOC_USE_GC__
#define array_malloc GC_malloc
#define array_realloc GC_realloc
#define array_free GC_free
#else
#define array_malloc(size) calloc(1, (size))
#define array_realloc realloc
#define array_free free
#endif // GC

#include <stdint.h>


#define _lang_array__Array_new(type, size) ((_lang_array__Array) { size, array_malloc(size * sizeof(type)), sizeof(type)});

#define _lang_array__Array_get(array, index, type) ( \
    (index < 0 || index >= array.rlength) ? \
    lang_Exception__Exception_throw((lang_Exception__Exception *) lang_Exception__OutOfBoundsException_new_noOrigin(index, array.rlength)), \
    *((type*) NULL) : \
    ((type*) array.data)[index])

#define _lang_array__Array_set(array, index, type, value) \
    (index < 0 || index >= array.rlength) ? \
    lang_Exception__Exception_throw((lang_Exception__Exception *) lang_Exception__OutOfBoundsException_new_noOrigin(index, array.rlength)), \
    *((type*) NULL) : \
    (((type*) array.data)[index] = value)

#define _lang_array__Array_realloc(array) { array_realloc(array.data, array.rlength * array.unitSize) }

#define _lang_array__Array_free(array) { array_free(array.data); }

typedef struct {
    size_t rlength;
    void* data;
	size_t unitSize;
} _lang_array__Array;


#endif // ___lang_array___

