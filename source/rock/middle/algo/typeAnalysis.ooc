import structs/ArrayList
import ../../frontend/Token
import ../[Type, BaseType, TypeDecl, CoverDecl, ClassDecl, Expression, EnumDecl]


distanceFromObject: func(type: BaseType) -> Int {
    ref := type ref as TypeDecl
    if(!ref) return -1

    distance := 0
    while(ref && ref instanceOf?(TypeDecl) && !ref as TypeDecl isObjectClass()) {
        if(ref superType && !ref superType as BaseType ref) return -1
        ref = ref superType as BaseType ref
        distance += 1
    }

    if(ref && !ref instanceOf?(TypeDecl)) return -1
    distance
}

_sugarLevelsEqual?: func(type1, type2: Type) -> Bool {
    while(type1 instanceOf?(SugarType)) {
        if(type1 class != type2 class) {
            return false
        }
        (type1, type2) = (type1 as SugarType inner, type2 as SugarType inner)
    }
    // If our first type was not sugarized and our second is, we must return false
    return !type2 instanceOf?(SugarType)
}

_createSugarWith: func(inner, sugar: Type) -> Type {
    construct := inner
    steps := ArrayList<Class> new()
    arrayExprs := ArrayList<Expression> new()

    /* Let's say our sugar was PointerType(ArrayType(Foo))
       We want to construct our inner (lets say Int) to this sugar like that:
       Int => ArrayType(Int) => PointerType(ArrayType(Int))
       So we add the steps we will take in reverse */
    while(sugar instanceOf?(SugarType)) {
        steps add(0, sugar class)
        if(sugar class == ArrayType) arrayExprs add(sugar as ArrayType expr)

        sugar = sugar as SugarType inner
    }

    arrayTypes := 0
    for(step in steps) {
        match step {
            case PointerType => construct = PointerType new(construct, construct token)
            case ArrayType => construct = ArrayType new(construct, arrayExprs get(arrayTypes), construct token)
                              arrayTypes += 1
            case ReferenceType => construct = ReferenceType new(construct, construct token)
            case => // Comon, how did you even get here?!
        }
    }
    construct
}

getInnermostType: func(type: Type) -> Type {
    while(type instanceOf?(SugarType)) {
        type = type as SugarType inner
    }
    type
}

findTypeRoot: func(t: BaseType) -> BaseType{
    if(t getRef() != null && t getRef() instanceOf?(CoverDecl)){
        if(t getRef() as CoverDecl getFromType() != null && t getRef() as CoverDecl getFromType() instanceOf?(BaseType)){
            return findTypeRoot(t getRef() as CoverDecl getFromType() as BaseType)
        }
    }
    t
}


baseRank : func -> Int{
    version (x86 || i386) {
        return 49
    } 
    99
}

/* C99 6.3.1.8 Usual arithmetic conversions */
numberTypeScore: func(t: BaseType) -> Int{
    realType := findTypeRoot(t)
    match(realType name){
        case "long double" => 1024
        case "double" => 512
        case "float" => 256

        case "unsigned long long" => 130
        case "uint64_t" => 128
        case "long long" => 127
        case "signed long long" => 127
        case "int64_t" => 125

        case "unsigned long" => 66
        case "uint32_t" => 64
        case "long" => 63
        case "signed long" => 63
        case "int32_t" => 61

        case "size_t" => baseRank() 
        case "ptrdiff_t" => baseRank() - 1
        case "ssize_t" => baseRank() - 2 

        case "unsigned int" => 34
        case "int" => 33
        case "signed int" => 33

        case "unsigned short" => 32
        case "signed short" => 30
        case "uint16_t" => 28

        case "unsigned char" => 18
        case "uint8_t" => 16
        case "Octet" => 15
        case "char" => 13
        case "signed char" => 13
        case "int8_t" => 11
        
        /*
         unexcepted type, this should never happen
         */
        case => 0
    }
}

numberType: func(type1, type2: BaseType) -> Type{
    s1 := numberTypeScore(type1) 
    s2 := numberTypeScore(type2)
    /*
     First, if the corresponding real type of either operand is long double, the other
     operand is converted, without change of type domain, to a type whose
     corresponding real type is long double.
     */
    if(s1 == 1024) return type1
    if(s2 == 1024) return type2
    /*
     Otherwise, if the corresponding real type of either operand is double, the other
     operand is converted, without change of type domain, to a type whose
     corresponding real type is double.
     */
    if(s1 == 512) return type1
    if(s2 == 512) return type2
    /*
     Otherwise, if the corresponding real type of either operand is float, the other
     operand is converted, without change of type domain, to a type whose
     corresponding real type is float.
     */
    if(s1 == 256) return type1
    if(s2 == 256) return type2
    /*
     Otherwise, the integer promotions are performed on both operands. Then the
     following rules are applied to the promoted operands:
     */

    /*
     If both operands have the same type, then no further conversion is needed.
     Otherwise, if both operands have signed integer types or both have unsigned
     integer types, the operand with the type of lesser integer conversion rank is
     converted to the type of the operand with greater rank.
     */
    if(s1 == s2) return type1
    /*
     Otherwise, if the operand that has unsigned integer type has rank greater or
     equal to the rank of the type of the other operand, then the operand with
     signed integer type is converted to the type of the operand with unsigned
     integer type.
     */
    if(s2 > s1 && s2 % 2 == 0) (type1, type2) = (type2, type1)
    if(s1 > s2 && s1 % 2 == 0){ return type1 }
    /*
     Otherwise, if the type of the operand with signed integer type can represent
     all of the values of the type of the operand with unsigned integer type, then
     the operand with unsigned integer type is converted to the type of the
     operand with signed integer type.
     */
    if(s2 - s1 >= 10 && s2 % 2 == 1) return type2
    if(s1 - s2 >= 10 && s1 % 2 == 1) return type1

    /*
     Otherwise, both operands are converted to the unsigned integer type
     corresponding to the type of the operand with signed integer type.
     */

    // in current rock, returning unresolved type will make rock blow up.
    // here we just return the type with higher score(INCORRECT)
    s1 < s2 ? type2 : type1
}

// Returns the clsoer common root of two types
// A common root is a type that represents both of the types it comes from
// For example, if Bar extends Foo and Baz extends Foo, Foo is the closer common root of Foo and Bar
findCommonRoot: func(type1, type2: Type) -> Type {

    coverAgainstClass := func(t1, t2: Type) -> Bool {
        // cover vs class -> incompatible
        if(t1 getRef() && t2 getRef()) {
            ref1 := t1 getRef()
            ref2 := t2 getRef()

            if(ref1 instanceOf?(CoverDecl) && ref2 instanceOf?(ClassDecl)\
            || ref2 instanceOf?(CoverDecl) && ref1 instanceOf?(ClassDecl)) {
                return true
            }
        }

        false
    }

    basic := func(t1, t2: Type) -> Type {
        if(t1 equals?(type2)) return t1
        if((t1 isNumericType() && t2 isNumericType()) || \
            t1 getRef() instanceOf?(EnumDecl) && t2 isNumericType() || \
            t1 isNumericType() && t2 getRef() instanceOf?(EnumDecl)) {
            if(t1 instanceOf?(BaseType) && t2 instanceOf?(BaseType)){
                return numberType(t1 as BaseType, t2 as BaseType)
            }
            // The root of an integer and a floating point type is the floating point type
            if(t2 isFloatingPointType()) return t2
            return t1
        }

        if(coverAgainstClass(t1, t2)) {
            return null
        }

        if(t1 getScore(t2) > 0 || t2 getScore(t1) > 0) {
            score1 := t1 getScore(t2)
            score2 := t2 getScore(t1)
            // note the reverse order: this happens because the more general type is t2 when t1 vs t2 > 0
            return score1 > score2 ? t2 : t1
        }

        if(t1 void? || t2 void?) {
            return voidType
        }
        null
    }

    candidate := basic(type1, type2)
    if(candidate) return candidate

    // Ok, time to do magic
    // First, we unwrap our types from tha sugar, after we make sure our types have the same amount of sugar
    if(!_sugarLevelsEqual?(type1, type2)) return null

    unwrapped1 := getInnermostType(type1)
    unwrapped2 := getInnermostType(type2)

    if(!unwrapped1 instanceOf?(BaseType) || !unwrapped2 instanceOf?(BaseType)) return null
    // Get the base type hidden under the sugar
    btype1 := unwrapped1 as BaseType
    btype2 := unwrapped2 as BaseType
    // Get the "distance" of our base types from Object
    distance1 := distanceFromObject(btype1)
    distance2 := distanceFromObject(btype2)

    if(distance1 == -1 || distance2 == -1) return null

    // Pointer vs class type -> Pointer
    if(btype1 instanceOf?(BaseType) && btype1 isPointer() && btype2 getRef() && btype2 getRef() instanceOf?(ClassDecl)) {
        return _createSugarWith(btype1, type1)
    } else if(btype2 instanceOf?(BaseType) && btype2 isPointer() && btype1 getRef() && btype1 getRef() instanceOf?(ClassDecl)) {
        return _createSugarWith(btype2, type1)
    }

    if(coverAgainstClass(btype1, btype2)) {
        return null
    }

    // Go closer and closer to Object with the type that has the biggest distance, checking to see if we can return a root every time
    type1Bigger := distance1 > distance2
    biggerDistance :=  type1Bigger ? distance1 : distance2
    newType := type1Bigger ? btype1 : btype2
    while(biggerDistance > 0) {
        newType = newType ref as TypeDecl superType
        candidate := basic(newType, type1Bigger ? btype2 : btype1)
        // If we do have a root, then re-sugarize it and return it!
        if(candidate) return _createSugarWith(candidate, type1)
        biggerDistance -= 1
    }

    null
}
