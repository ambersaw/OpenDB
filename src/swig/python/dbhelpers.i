%{
#include <libgen.h>
#include "lefin.h"
#include "lefout.h"
#include "defin.h"
#include "defout.h"
#include <fstream>

odb::dbLib*
read_lef(odb::dbDatabase* db, const char* path)
{
  lefin lefParser(db, false);
  const char *libname = basename(const_cast<char*>(path));
  if (!db->getTech()) {
    return lefParser.createTechAndLib(libname, path);
  } else {
    return lefParser.createLib(libname, path);
  }
}

odb::dbBlock*
read_def(odb::dbDatabase* db, std::string path)
{
  std::vector<odb::dbLib *> libs;
  for (dbLib *lib : db->getLibs()) {
    libs.push_back(lib);
  }
  defin defParser(db);
  defParser.continueOnErrors();
  return defParser.createChip(libs, path.c_str());
}

int
write_def(odb::dbBlock* block, const char* path,
	      odb::defout::Version version = odb::defout::Version::DEF_5_8)
{
  defout writer;
  writer.setVersion(version);
  return writer.writeBlock(block, path);
}

int
write_lef(odb::dbLib* lib, const char* path)
{
  std::ofstream os;
  os.exceptions(std::ofstream::badbit | std::ofstream::failbit);
  os.open(path);
  lefout writer(os);
  writer.writeTechAndLib(lib);
  return 1;
}

odb::dbDatabase*
read_db(odb::dbDatabase* db, const char* db_path)
{
  FILE *fp = fopen(db_path, "rb");
  if (!fp) {
    int errnum = errno;
    fprintf(stderr, "Error opening file: %s\n", strerror( errnum ));
    fprintf(stderr, "Errno: %d\n", errno);
    return NULL;
  }
  db->read(fp);
  fclose(fp);
  return db;
}

int
write_db(odb::dbDatabase* db, const char* db_path)
{
  FILE *fp = fopen(db_path, "wb");
  if (!fp) {
    int errnum = errno;
    fprintf(stderr, "Error opening file: %s\n", strerror( errnum ));
    fprintf(stderr, "Errno: %d\n", errno);
    return errno;
  }
  db->write(fp);
  fclose(fp);
  return 1;
}

int *new_int(int ivalue) {
  int *i = (int *) malloc(sizeof(ivalue));
  *i = ivalue;
  return i;
}
int get_int(int *i) {
  return *i;
}

bool set_str_prop(void* obj, const std::string prop_name, const std::string value)
{
  if (odb::dbStringProperty::create((odb::dbObject*)obj, prop_name.c_str(), value.c_str()) != NULL) {
    return 1;
  } else {
    return 0;
  }
}
bool set_bool_prop(void* obj, const std::string prop_name, const bool value)
{
  if (odb::dbBoolProperty::create((odb::dbObject*)obj, prop_name.c_str(), value) != NULL) {
    return 1;
  } else {
    return 0;
  }
}
bool set_int_prop(void* obj, const std::string prop_name, const int value)
{
  if (odb::dbIntProperty::create((odb::dbObject*)obj, prop_name.c_str(), value) != NULL) {
    return 1;
  } else {
    return 0;
  }
}
bool set_double_prop(void* obj, const std::string prop_name, const double value)
{
  if (odb::dbDoubleProperty::create((odb::dbObject*)obj, prop_name.c_str(), value) != NULL) {
    return 1;
  } else {
    return 0;
  }
}
std::string get_str_prop(void* obj, const std::string prop_name)
{
  auto prop = odb::dbStringProperty::find((odb::dbObject*)obj, prop_name.c_str());
  if (prop != NULL) {
    return prop->getValue();
  } else {
    // printf("No Property %s exists\n", prop_name.c_str());
    return "";
  }
}
bool get_bool_prop(void* obj, const std::string prop_name)
{
  auto prop = odb::dbBoolProperty::find((odb::dbObject*)obj, prop_name.c_str());
  if (prop != NULL) {
    return prop->getValue();
  } else {
    // printf("No Property %s exists\n", prop_name.c_str());
    return 0;
  }
}
int get_int_prop(void* obj, const std::string prop_name)
{
  auto prop = odb::dbIntProperty::find((odb::dbObject*)obj, prop_name.c_str());
  if (prop != NULL) {
    return prop->getValue();
  } else {
    // printf("No Property %s exists\n", prop_name.c_str());
    return 0;
  }
}
double get_double_prop(void* obj, const std::string prop_name)
{
  auto prop = odb::dbDoubleProperty::find((odb::dbObject*)obj, prop_name.c_str());
  if (prop != NULL) {
    return prop->getValue();
  } else {
    // printf("No Property %s exists\n", prop_name.c_str());
    return 0;
  }
}
void remove_prop(void* obj, const std::string prop_name)
{
  odb::dbProperty* prop = odb::dbProperty::find((odb::dbObject*)obj, prop_name.c_str());
  if (prop != NULL) {
    odb::dbProperty::destroy(prop);
  }
}
odb::dbSet<odb::dbProperty> get_properties(void* object);

%}

odb::dbLib*
read_lef(odb::dbDatabase* db, const char* path);
odb::dbBlock*
read_def(odb::dbDatabase* db, std::string path);

int
write_def(odb::dbBlock* block, const char* path,
	      odb::defout::Version version = odb::defout::Version::DEF_5_8);
int
write_lef(odb::dbLib* lib, const char* path);

odb::dbDatabase* read_db(odb::dbDatabase* db, const char* db_path);
int write_db(odb::dbDatabase* db, const char* db_path);
int *new_int(int ivalue);
int get_int(int *i);
void remove_prop(void* obj, const std::string prop_name);

std::string get_str_prop(void* obj, const std::string prop_name);
bool set_str_prop(void* obj, const std::string prop_name, const std::string value);
bool get_bool_prop(void* obj, const std::string prop_name);
bool set_bool_prop(void* obj, const std::string prop_name, const bool value);
int get_int_prop(void* obj, const std::string prop_name);
bool set_int_prop(void* obj, const std::string prop_name, const int value);
double get_double_prop(void* obj, const std::string prop_name);
bool set_double_prop(void* obj, const std::string prop_name, const double value);
