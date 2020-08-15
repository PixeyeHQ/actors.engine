import actors
import random

type CompA = object
  arg: int
type CompB = object
  arg: int
type CompC = object
  arg: int
type CompD = object
  arg: int
type CompF = object
  arg: int

app.add CompA
app.add CompB
app.add CompC
app.add CompD
app.add CompF

var game = app.addLayer()
var gr_abc = game.group(CompA,CompB,CompC)
var gr_ab = game.group(CompA,CompB)
var gr_a = game.group(CompA)

proc mk_abc*(layer: LayerID): ent {.discardable.} =
  result = layer.entity()
  result.get CompA
  result.get CompB
  result.get CompC
proc mk_ab*(layer: LayerID): ent {.discardable.} =
  result = layer.entity()
  result.get CompA
  result.get CompB

proc mk_a*(layer: LayerID): ent {.discardable.} =
  result = layer.entity()
  result.get CompA

var size = 15000
var randoms = newSeq[int](size)

for i in 0..<size:
  randoms[i] = i mod 3

randomize(getTime().toUnix)
randoms.shuffle()

for i in 0..<size:
  if randoms[i] == 0:
    game.mk_abc()
  elif randoms[i] == 1:
    game.mk_ab()
  elif randoms[i] == 2:
    game.mk_a()

game.ecs.execute()

var steps = 60*3600
profile.start "dynamic":
  for st in 0..steps:
    for e, ca in comps(CompA):
      ca.arg+=1
profile.start "groups":
  for st in 0..steps:
    for e in gr_a:
      e.ca.arg+=1

profile.log
