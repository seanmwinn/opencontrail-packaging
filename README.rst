============================
OpenContrail Packaging
============================

Creates debian packages which can be used to install Juniper's OpenContrail SDN networking solution.

Packages can be easily built using the included Dockerfile

To build the docker image run:

.. code-block:: console

    $ docker build -t contrail-packaging .

Then you can create debian packages by running the image using volume mounts for /lib/modules and /usr/lib to ensure that kernel-headers are available in the build process:


.. code-block:: console

    $ docker run --rm -v /lib/modules:/lib/modules -v /usr/src:/usr/src -v $(OUTPUT):$(PKG_OUT) contrail-packaging $(MAKE_ARGS) $(MAKE_TARGET)

To build branches other than the master branch, modify the CONTRAIL_BRANCH environment variable for the container build step.

The default entrypoint of the project is ``make`` and the default command is
``-f $(MAKE_ARGS) $(MAKE_TARGET)`` which will make the packages from the makefile using the specified targets.

The default makefile is ``/var/workspace/pkg/packages.make`` and the default target is ``all``.
