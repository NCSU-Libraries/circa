# ansible-solr

Ansible role to install Apache Solr and create a core that uses configuration
files contained in a project repo. For use with many NCSU open source projects.

## Required variables

**confdir** - Full path to the directory containing Solr configuration files.
These will replace files that are created by default in the core's
`conf` directory.

**cores** [list] - names of cores to create (all core will share a common configuration)

## Optional variables and defaults

**version** - Solr version. Default: `"6.6.2"`

**group** - File group ownership. Default: `deploy`
