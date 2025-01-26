CREATE MIGRATION m1wnw32nt2su5i64ncgbp6b4wkuc27vxxart54qw7odp7cl5mmihna
    ONTO m1gejt3jtdbq4ixv25ocfklxo55gvsbtyhdkr2hyrbcis3jeo4osrq
{
  CREATE ABSTRACT TYPE default::BaseObject {
      CREATE REQUIRED PROPERTY created_at: std::datetime {
          SET default := (std::datetime_current());
      };
      CREATE REQUIRED PROPERTY updated_at: std::datetime {
          SET default := (std::datetime_current());
      };
      CREATE REQUIRED PROPERTY version: std::int16 {
          SET default := 1;
      };
  };
  CREATE SCALAR TYPE default::Environment EXTENDING enum<prod, stag>;
  CREATE TYPE default::Namespace EXTENDING default::BaseObject {
      CREATE PROPERTY active: std::bool {
          SET default := true;
      };
      CREATE REQUIRED PROPERTY config: std::str;
      CREATE REQUIRED PROPERTY environment: default::Environment;
      CREATE REQUIRED PROPERTY name: std::str {
          CREATE CONSTRAINT std::exclusive;
      };
  };
};
