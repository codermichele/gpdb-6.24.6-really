drop extension if exists gp_debug_numsegments;
create extension gp_debug_numsegments;

--
-- GOOD: valid text values: random, full, minimal
--

select gp_debug_reset_create_table_default_numsegments();
select gp_debug_get_create_table_default_numsegments();
create table t_reset_first (c1 int, c2 int) distributed by (c1);

select gp_debug_reset_create_table_default_numsegments('random');
select gp_debug_get_create_table_default_numsegments();
create table t_reset_random (c1 int, c2 int) distributed by (c1);
select localoid::regclass, attrnums, policytype
  from gp_distribution_policy
 where localoid='t_reset_random'::regclass
   and numsegments between 1 and 3;
drop table t_reset_random;

select gp_debug_reset_create_table_default_numsegments('full');
select gp_debug_get_create_table_default_numsegments();
create table t_reset_full (c1 int, c2 int) distributed by (c1);

select gp_debug_reset_create_table_default_numsegments('minimal');
select gp_debug_get_create_table_default_numsegments();
create table t_reset_minimal (c1 int, c2 int) distributed by (c1);

select gp_debug_reset_create_table_default_numsegments('FULL');
create table "t_reset_FULL" (c1 int, c2 int) distributed by (c1);

select gp_debug_reset_create_table_default_numsegments('Full');
create table "t_reset_Full" (c1 int, c2 int) distributed by (c1);

select gp_debug_reset_create_table_default_numsegments('fulL');
create table "t_reset_fulL" (c1 int, c2 int) distributed by (c1);

--
-- GOOD: valid integer values between [1, gp_num_contents_in_cluster]
--

select gp_debug_reset_create_table_default_numsegments(1);
select gp_debug_get_create_table_default_numsegments();
create table t_reset_1 (c1 int, c2 int) distributed by (c1);

select gp_debug_reset_create_table_default_numsegments(2);
select gp_debug_get_create_table_default_numsegments();
create table t_reset_2 (c1 int, c2 int) distributed by (c1);

select gp_debug_reset_create_table_default_numsegments(3);
select gp_debug_get_create_table_default_numsegments();
create table t_reset_3 (c1 int, c2 int) distributed by (c1);

select c.relname, d.attrnums, d.policytype, d.numsegments
  from gp_distribution_policy d
  join pg_class c
    on d.localoid=c.oid
   and c.relname like 't_reset_%';

--
-- BAD: syntax error
--

select gp_debug_reset_create_table_default_numsegments('reset');
select gp_debug_reset_create_table_default_numsegments('unknown');
select gp_debug_reset_create_table_default_numsegments('  full');
select gp_debug_reset_create_table_default_numsegments('full  ');
select gp_debug_reset_create_table_default_numsegments('1');
select gp_debug_reset_create_table_default_numsegments('');

--
-- BAD: out of range
--

select gp_debug_reset_create_table_default_numsegments(0);
select gp_debug_reset_create_table_default_numsegments(-1);
select gp_debug_reset_create_table_default_numsegments(4);
select gp_debug_reset_create_table_default_numsegments(999);

--
-- BAD: cannot execute on segments
--

select gp_debug_reset_create_table_default_numsegments(1)
  from gp_dist_random('gp_id');
