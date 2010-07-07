import io/File, text/EscapeSequence
import structs/[HashMap, ArrayList, List, OrderedMultiMap]
import ../frontend/[Token, BuildParams, PathList, AstBuilder]
import ../utils/FileUtils
import Node, FunctionDecl, Visitor, Import, Include, Use, TypeDecl,
       FunctionCall, Type, Declaration, VariableAccess, OperatorDecl,
       Scope, NamespaceDecl, BaseType, FuncType
import tinker/[Response, Resolver, Trail]

Module: class extends Node {

    timesImported := 0
    timesLooped := 0

    path, fullName, simpleName, packageName, underName, pathElement : String
    main := false

    types      := OrderedMultiMap<String, TypeDecl> new()
    functions  := OrderedMultiMap<String, FunctionDecl> new()
    operators  := ArrayList<OperatorDecl> new()

    includes   := ArrayList<Include> new()
    imports    := ArrayList<Import> new()
    namespaces := HashMap<String, NamespaceDecl> new()
    uses       := ArrayList<Use> new()

    funcTypesMap := HashMap<String, FuncType> new()

    body       := Scope new()

    lastModified : Long

    params: BuildParams

    init: func ~module (.fullName, =pathElement, =params, .token) {
        super(token)
        this path = fullName clone() replace('/', File separator)
        this fullName = fullName replace(File separator, '/')
        idx := this fullName lastIndexOf('/')

        match idx {
            case -1 =>
                simpleName = this fullName clone()
                packageName = ""
            case =>
                simpleName = this fullName substring(idx + 1)
                packageName = this fullName substring(0, idx)
        }

        underName = sanitize(this fullName clone())
        packageName = sanitize(packageName)
    }

    getLoadFuncName: func -> String { getUnderName() + "_load" }
    getFullName:     func -> String { fullName }
    getUnderName:    func -> String { underName }
    getPathElement:  func -> String { pathElement }
    getSourceFolderName: func -> String {
        File new(File new(getPathElement()) getAbsolutePath()) name()
    }

    collectDeps: func -> List<Module> {
        _collectDeps(ArrayList<Module> new())
    }

    _collectDeps: func (list: List<Module>) -> List<Module> {
        list add(this)
		for(imp in getAllImports()) {
			if(!list contains(imp getModule())) {
				imp getModule() _collectDeps(list)
			}
		}
        list
    }

    addFuncType: func (hashName: String, funcType: FuncType) {
        if(!funcTypesMap contains(hashName)) {
            funcTypesMap put(hashName, funcType)
        }
    }

    sanitize: func(str: String) -> String {
        result := str clone()
        for(i in 0..result length()) {
            current := result[i]
            if(!current isAlphaNumeric()) {
                result[i] = '_'
            }
        }
        if(!result[0] isAlpha()) result = '_' + result
        result
    }

    addFunction: func (fDecl: FunctionDecl) {
        // don't add empty-named functions
        if(fDecl name isEmpty()) return

        hash := TypeDecl hashName(fDecl)
        old := functions get(hash)
        if (old != null) {
            if ((old verzion == fDecl verzion) ||
                (old verzion != null && fDecl verzion != null && old verzion equals(fDecl verzion))) {
                fDecl token printMessage("Redefinition of '%s'%s" format(old getName(), old verzion ? " in version " + old verzion toString() : ""), "[ERROR]")
                old   token throwError("...first definition was here: ")
                return
            }
            if (fDecl verzion != null && !fDecl verzion isSatisfied(params)) {
                //"%s is better-scored than %s, retaining." printfln(old verzion toString(), fDecl verzion toString())
                return
            } //else {
            //    "%s is better-scored than %s, swapping!" printfln(fDecl verzion toString(), old verzion toString())
            //}
        }
        functions put(hash, fDecl)
    }

    addType: func (tDecl: TypeDecl) {
        old := types get(tDecl name) as TypeDecl
        if (old != null) {
            if ((old verzion == tDecl verzion) ||
                (old verzion != null && tDecl verzion != null && old verzion equals(tDecl verzion))) {
                tDecl token printMessage("Redefinition of '%s'%s" format(tDecl name, old verzion ? " in version " + old verzion toString() : ""), "[ERROR]")
                old   token throwError("...first definition was here: ")
            }
            if (tDecl verzion != null && !tDecl verzion isSatisfied(params)) {
                //"%s is better-scored than %s, retaining." printfln(old verzion toString(), tDecl verzion toString())
                return
            } //else {
            //    "%s is better-scored than %s, swapping!" printfln(tDecl verzion toString(), old verzion toString())
            //}
        }

        types put(tDecl name, tDecl)
        if(tDecl getMeta()) types put(tDecl getMeta() name, tDecl getMeta())
    }

    addOperator: func (oDecl: OperatorDecl) {
        operators add(oDecl)
    }

    addImport: func (imp: Import) {
        imports add(imp)
    }

    addInclude: func (inc: Include) {
        includes add(inc)
    }

    addNamespace: func (nDecl: NamespaceDecl) {
        namespaces put(nDecl getName(), nDecl)
    }

    hasNamespace: func (name: String) -> Bool {
        namespaces contains(name)
    }

    getNamespace: func (name: String) -> NamespaceDecl {
        namespaces get(name)
    }

    addUse: func (use1: Use) {
        uses add(use1)
    }

    getOperators: func -> List<OperatorDecl> { operators }
    getFunctions: func -> OrderedMultiMap<String, FunctionDecl>  { functions }
    getTypes:     func -> OrderedMultiMap<String, TypeDecl>  { types }
    getUses:      func -> List<Use>          { uses }

    accept: func (visitor: Visitor) { visitor visitModule(this) }

    getPath: func ~full -> String { path }

    getPath: func (suffix: String) -> String {
        last := (File new(pathElement) name())
        return (last + File separator) + fullName replace('/', File separator) + suffix
    }

    getOocPath: func -> String {
        path + ".ooc"
    }

    getParentPath: func -> String {
        // FIXME that's sub-optimal
        fileName := pathElement + File separator + fullName + ".ooc"
        parentPath := File new(fileName) parent() path
        return parentPath
    }

    /** return global (e.g. non-namespaced) imports */
    getGlobalImports: func -> List<Import> { imports }

    /** return all imports, including those in namespaces */
    getAllImports: func -> List<Import> {
        if(namespaces isEmpty()) return imports

        list := ArrayList<Import> new()
        list addAll(getGlobalImports())
        for(namespace in namespaces)
            list addAll(namespace getImports())
        return list
    }

    resolveAccess: func (access: VariableAccess, res: Resolver, trail: Trail) -> Int {

        //printf("Looking for %s in %s\n", access toString(), toString())

        // TODO: optimize by returning as soon as the access is resolved
        resolveAccessNonRecursive(access, res, trail)

        for(imp in getGlobalImports()) {
            imp getModule() resolveAccessNonRecursive(access, res, trail)
        }

        namespace := namespaces get(access getName())
        if(namespace != null) {
            //printf("resolved access %s to namespace %s!\n", access getName(), namespace toString())
            access suggest(namespace)
        }

        0

    }

    resolveAccessNonRecursive: func (access: VariableAccess, res: Resolver, trail: Trail) -> Int {

        ref := null as Declaration

        for(f in functions) {
            if(f name == access name) {
                access suggest(f)
            }
        }

        ref = types get(access name)
        if(ref != null && access suggest(ref)) {
            return 0
        }

        // That's actually the only place we want to resolve variables from the
        // body - precisely because they're global
        body resolveAccess(access, res, trail)

        0

    }

    resolveCall: func (call: FunctionCall, res: Resolver, trail: Trail) -> Int {
        if(call isMember()) {
            return 0 // hmm no member calls for us
        }

        resolveCallNonRecursive(call, res)

        for(imp in getGlobalImports()) {
            imp getModule() resolveCallNonRecursive(call, res)
        }

        0
    }

    resolveCallNonRecursive: func (call: FunctionCall, res: Resolver) {

        //printf(" >> Looking for function %s in module %s!\n", call name, fullName)
        fDecl : FunctionDecl = null
        fDecl = functions get(TypeDecl hashName(call name, call suffix))
        if(fDecl) {
            call suggest(fDecl)
        }

        for(fDecl in functions) {
            if(fDecl getName() == call getName() && (call getSuffix() == null || call getSuffix() == fDecl getSuffix())) {
                if(call debugCondition()) printf("Suggesting fDecl %s for call %s\n", fDecl toString(), call toString())
                call suggest(fDecl)
            }
        }

    }

    resolveType: func (type: BaseType) {

        ref : Declaration = null

        ref = types get(type name)
        if(ref != null && type suggest(ref)) {
            return
        }

        for(imp in getGlobalImports()) {
            ref = imp getModule() types get(type name)
            if(ref != null && type suggest(ref)) {
                break
            }
        }

    }

    /**
     * Parse the imports of this module.
     * 
     * If resolver is non-null, it means there's a new import that
     * we expect to add to the resolvers list.
     */
    parseImports: func (resolver: Resolver) {

        for(imp: Import in getAllImports()) {
            if(imp module != null) continue

            impPath = null, impElement = null : File
            path = null: String
            AstBuilder getRealImportPath(imp, this, params, path&, impPath&, impElement&)
            if(impPath == null) {
                imp token throwError("Module not found in sourcepath " + imp path)
            }

            absolutePath := File new(impPath path) getAbsolutePath()

            cached : Module = null
            cached = AstBuilder cache get(absolutePath)

            impLastModified := impPath lastModified()

            if(cached == null || impLastModified > cached lastModified) {
                if(cached && resolver params veryVerbose) {
                    printf("%s has been changed, recompiling... (%d vs %d), impPath = %s\n", path, File new(impPath path) lastModified(), cached lastModified, impPath path);
                }

                cached = Module new(path[0..(path length()-4)], impElement path, params, nullToken)
                AstBuilder cache remove(impPath path)
                AstBuilder cache put(File new(impPath path) getAbsolutePath(), cached)
                imp setModule(cached)

                cached token = Token new(0, 0, cached)
                if(resolver != null) {
                    resolver addModule(cached)
                }
                cached lastModified = impLastModified
                AstBuilder new(impPath path, cached, params)
                cached parseImports(resolver)
            }
            imp setModule(cached)
        }
    }

    resolve: func (trail: Trail, res: Resolver) -> Response {

        finalResponse := Responses OK

        trail push(this)

        {
            response := body resolve(trail, res)
            if(!response ok()) {
                if(res params veryVerbose) printf("response of body = %s\n", response toString())
                finalResponse = response
            }
        }

        for(tDecl in types) {
            if(tDecl isResolved()) continue
            response := tDecl resolve(trail, res)
            if(!response ok()) {
                if(res params veryVerbose) printf("response of tDecl %s = %s\n", tDecl toString(), response toString())
                finalResponse = response
            }
        }

        for(fDecl in functions) {
            if(fDecl isResolved()) continue
            response := fDecl resolve(trail, res)
            if(!response ok()) {
                if(res params veryVerbose) printf("response of fDecl %s = %s\n", fDecl toString(), response toString())
                finalResponse = response
            }
        }

        for(oDecl in operators) {
            if(oDecl isResolved()) continue
            response := oDecl resolve(trail, res)
            if(!response ok()) {
                if(res params veryVerbose) printf("response of oDecl %s = %s\n", oDecl toString(), response toString())
                finalResponse = response
            }
        }

        trail pop(this)

        return finalResponse
    }

    toString: func -> String {
        class name + ' ' + fullName
    }

    replace: func (oldie, kiddo: Node) -> Bool { false }

    isScope: func -> Bool { true }

}
