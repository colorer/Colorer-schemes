ifeq ($(VAR1), var1)
  TEST = var1
else ifeq ($(VAR2), var2)
  TEST = var2
else
  $(error TEST)
endif

export $(TEST)

ifndef FOO
else ifdef BAR
  X = 1
else ifneq ($(Y),)
  X = 2
else ifndef BAZ
  X = 3
endif

export
export FOO
unexport $(TEST)
export ASSIGNED = value
