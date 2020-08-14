import strutils
import macros
import strformat
import ../actors_ecs_h


proc formatComponentAlias*(s: var string) {.used.}=
  var indexes : array[8,int]
  var i = 0
  var index = 0
  while i<s.len:
     if s[i] in 'A'..'Z': 
       indexes[index] = i
       index += 1
       assert index < 7, "too long name"

     i+=1
  if index>=2:
    delete(s,1,indexes[1]-1)
  s = toUpperAscii(s[0]) & substr(s, 1)

proc formatComponent*(s: var string) {.used.}=
  var indexes : array[8,int]
  var i = 0
  var index = 0
  while i<s.len:
     if s[i] in 'A'..'Z': 
       indexes[index] = i
       index += 1
       assert index < 7, "too long name"

     i+=1
  if index>=2:
    delete(s,1,indexes[1]-1)
  s = toLowerAscii(s[0]) & substr(s, 1)

proc formatComponentLong*(s: var string) {.used.}=
  var indexes : array[8,int]
  var i = 0
  var index = 0
  while i<s.len:
     if s[i] in 'A'..'Z': 
       indexes[index] = i
       index += 1
       assert index < 7, "too long name"

     i+=1
  if index>=2:
    delete(s,1,indexes[1]-1)
  s = toUpperAscii(s[0]) & substr(s, 1)

macro formatComponentPrettyAndLong*(T: typedesc): untyped {.used.}=
  let tName = strVal(T)
  var proc_name = tName  
  proc_name  = toLowerAscii(proc_name[0]) & substr(proc_name, 1)
  formatComponent(proc_name)
  var source = &("""
  template `{proc_name}`*(self: ent): ptr {tName} =
      impl_get(self,{tName})
      """)
  result = parseStmt(source)

macro formatComponentPretty*(t: typedesc): untyped {.used.}=
  let tName = strVal(t)
  var proc_name = tName  
  formatComponent(proc_name)
  var source = ""
  source = &("""
    template `{proc_name}`*(self: ent): ptr {tName} =
        impl_get(self,{tName})
        """)

  result = parseStmt(source)

func sortStorages*(x,y: CompStorageBase): int =
  let cx = x.entities
  let cy = y.entities
  if cx.len <= cy.len: -1
  else: 1
func sortStoragesByType*(x,y: CompStorageBase): int =
  let cx = x.entities
  let cy = y.entities
  if cx.len <= cy.len: -1
  else: 1

template isGrouped*(entity: ptr EntityMeta, group: Group): bool {.used.} =
  if group.id in entity.signature_groups:
    true
  else: false

template isValidForGroup*(eid: int, group: Group): bool {.used.} =
  var result = true
  for cid in group.signature:
    let storage = storages[cid.int]
    if storage.indices[eid] == int.high:
      result = false
      break
  if result:
    for cid in group.signature_excl:
      let storage = storages[cid.int]
      if storage.indices[eid] != int.high:
        result = false
        break
  result

# macro formatester*(t: typedesc): untyped {.used.} =
#   let tName = strVal(t)
#   var proc_name = tName  
#   formatComponent(proc_name)
#   var source = ""
#   source = &("""
#     template getComper*(_:{tName}, arg: untyped): untyped =
#       var {proc_name} = storage.comps.addr
#         """)

#   result = parseStmt(source)