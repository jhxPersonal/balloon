JAVA_INCLUDES=-I/usr/lib/jvm/java/include/linux -I/usr/lib/jvm/java/include

INCLUDES=${JAVA_INCLUDES} -I.

CXXFLAGS=-DASSERT -DDEBUG ${INCLUDES} -std=c++0x -DLinux -c -g -fPIC

CFLAGS=-DASSERT -DDEBUG ${INCLUDES} -DLinux -c -g -fPIC

LDFLAGS=-z noexecstack -shared -Wl,-soname,libballoon.so

SRCDIR=src/main/native

JAVA_SRCDIR=src/main/java

JAVA_LIB_PKG=com.redhat.openjdk.balloon
JAVA_LIB_CLASS_NAMES=MemoryManager HeapState GCState BalloonManager
JAVA_TEST_CLASS_NAMES=Test

JAVA_LIB_PATH=com/redhat/openjdk/balloon
JAVA_LIB_SRCS=$(JAVA_LIB_CLASS_NAMES:%=$(JAVA_SRCDIR)/$(JAVA_LIB_PATH)/%.java)

JAVA_TEST_SRC=$(JAVA_TEST_CLASS_NAMES:%=$(JAVA_SRCDIR)/%.java)

TARGETDIR=target

JAVA_CLASSES_DIR=$(TARGETDIR)/classes
JAVA_LIB_CLASSES=$(JAVA_LIB_CLASS_NAMES:%=$(JAVA_CLASSES_DIR)/$(JAVA_LIB_PATH)/%.class)
JAVA_TEST_CLASSES=$(JAVA_TEST_CLASS_NAMES:%=$(JAVA_CLASSES_DIR)/%.class)

CC=gcc
CXX=g++
LD=g++

# all produces the agent lib and a jar containing the agent Java classes and class Test
all: $(TARGETDIR) $(TARGETDIR)/libballoon.so $(JAVA_TEST_CLASSES) $(TARGETDIR)/balloondriver-1.0.0.jar

# all32 builds a 32 bit version as per all

all32:: CFLAGS += -m32

all32:: CXXFLAGS += -m32

all32:: LDFLAGS += -m32

all32: all

# dist just produces the agent lib and a jar containing the agent Java classes without class Test

dist: clean $(TARGETDIR) $(TARGETDIR)/libballoon.so $(TARGETDIR)/balloondriver-1.0.0.jar

# dist32 builds a 32 bit version as per dist

dist32:: CFLAGS += -m32

dist32:: CXXFLAGS += -m32

dist32:: LDFLAGS += -m32

dist32:: dist

clean:
	rm -rf $(TARGETDIR)

$(TARGETDIR):
	mkdir $(TARGETDIR)

$(TARGETDIR)/libballoon.so: $(TARGETDIR)/balloonagent.o $(TARGETDIR)/balloonutil.o
	$(LD) $(LDFLAGS) -o $@ $^


$(TARGETDIR)/%.o: $(SRCDIR)/%.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

$(TARGETDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -o $@ $<

$(TARGETDIR)/balloondriver-1.0.0.jar: $(JAVA_LIB_CLASSES)
	mvn install

$(JAVA_LIB_CLASSES): $(JAVA_LIB_SRCS)
	mvn -P lib compile

$(JAVA_TEST_CLASSES): $(JAVA_TEST_SRCS)
	mvn -P test compile

