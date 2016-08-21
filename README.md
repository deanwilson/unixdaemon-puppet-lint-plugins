# Unixdaemon Puppet-lint Plugin Repository

This meta-repo exists as a convenient, single location, introduction
to all my `puppet-lint` plugins. Below you'll find a brief introduction
to each plugin and a link to the repo that contains it.

## [puppet-lint absolute template path check](https://github.com/deanwilson/puppet-lint-absolute_template_path-check)
A new check for puppet-lint that checks template paths are in the
relative `template('example/template.erb')` form rather than the absolute
`template('/etc/puppet/modules/example/templates/template.erb')` format.



## [puppet-lint concatenated template files check](https://github.com/deanwilson/puppet-lint-concatenated_template_files-check)
Extends puppet-lint to ensure all `template` functions expand a single
file, rather than unexpectedly concatenating multiple template files in
to a single string.

There is a slightly obscure difference in the way that puppet handles
multiple file names when calling the `file` or `template` functions. In
the case of the `file` function it will return the contents of the first
file found from those given, skipping any that don’t exist. The
`template` function on the other hand will evaluate all of the specified
templates and return their outputs concatenated into a single string.

This is very rarely what you want. Assuming absent_file is, well absent,
and real_file is in the correct place this will return the content of real_file.

    class multi_templated_file {
      file { '/tmp/symbolic-mode':
        content => file('mymodule/absent_file.erb', 'mymodule/real_file.erb'),
      }
    }

However if both of these files exist then the contents will be
concatenated and the combination of all given files will be returned to
`content`.

    class multi_templated_file {
      file { '/tmp/symbolic-mode':
        content => template('mymodule/first_file.erb', 'mymodule/second_file.erb'),
      }
    }

If you do want to select from multiple templates then
[puppet-multitemplate](https://github.com/deanwilson/puppet-multitemplate)
will give you a new function that behaves as you'd expect.



## [puppet-lint explicit Hiera class parameter lookup check](https://github.com/deanwilson/puppet-lint-explicit_hiera_class_param_lookup-check)
Extends puppet-lint to ensure there are no explicit calls to hiera()
in the class parameters.

In our code base we would rather have a class lookup values for its
parameters using Puppets automatic data binding functionality rather than
scatter a number of direct, unpredictably name spaced, hiera calls
throughout our manifests. This puppet-lint plugin helps us with that goal by
finding any explicit `hiera` calls in a classes parameter section.

    class no_explicit_lookups (
      $my_content = hiera('my::nested::key', 'baz')
    ) {
      file { '/tmp/foo':
        content => $my_content,
      }
    }



## [puppet-lint no_cron_resources check](https://github.com/deanwilson/puppet-lint-no_cron_resources-check)
Extends puppet-lint to ensure no cron resources are contained in
the catalog.

[![Build Status](https://travis-ci.org/deanwilson/puppet-lint-no_cron_resources-check.svg?branch=master)](https://travis-ci.org/deanwilson/puppet-lint-no_cron_resources-check)

Sometimes there are certain `puppet` resource types that you don't want
to include in your code base. This could be a fragile one like `cron`,
an easy to abuse one like `augeas` or one you just dislike the name
of, I'm looking at you `computer`. This `puppet-lint` check will
display a warning each time it finds a usage of that resource, in this
case `cron`.



## [puppet-lint no ERB templates check](https://github.com/deanwilson/puppet-lint-no_erb_template-check)
As part of the migration to a cleaner, Puppet 4 enhanced, code base one
of the suggestions is to move from the old ERB (Embedded Ruby)
templates to the newer, kinder, gentler `epp` (Embedded Puppet
Programming) equivalents. You can find more details in the
[Templating with Embedded Puppet Programming Language - EPP](http://puppet-on-the-edge.blogspot.co.uk/2014/03/templating-with-embedded-puppet.html) blog post.

The lint check in this plugin will raise a warning anywhere a
`template()` or `inline_template()` function call is found in your
manifests. It's worth noting that this plugin will probably raise a lot
of warnings if you use external modules that maintain Puppet 3
compatibility; and will be of most use in new, Puppet 4 only code bases.



## [puppet-lint no file resource path attributes](https://github.com/deanwilson/puppet-lint-no_file_path_attribute-check)
Extends puppet-lint to ensure all file resources use the resource
title to indicate the file to manage rather than a symbolic name
and the `path` attribute.

Instead of this:

    class path_attribute {
      file { 'ssh_config_file':
        path    => '/etc/ssh/sshd_config',
        content => 'Bad path attribute, bad.',
      }
    }

I think, and this check complains unless, you use this format:

    class good_namevar {
      file { '/etc/ssh/sshd_config':
        content => 'Good namevar',
      }
    }

There is nothing technically wrong with the first form but I'd rather
know what the resource type is, and what it manages, without having to read further in to the resouece.
Oddly I have no issues with `exec` resources with `command` attributes being
[written in this style](http://www.puppetcookbook.com/posts/nicer-exec-names.html).



## [puppet-lint no symbolic file modes check](https://github.com/deanwilson/puppet-lint-no_symbolic_file_modes-check)
Extends puppet-lint to ensure all file resource modes are defined as octal
values and not symbolic ones.

While symbolic modes can be more flexible than numeric modes they allow
you to become less absolute about the permissions a file will end up
with. `mode => 'ug+w'` for example will set the user and group write
bits, without affecting any other bits, leaving you unable to determine
the files final permissions from just reading the puppet code.

    # a good, octal mode.
    class octal_file_mode {
      file { '/tmp/octal-mode':
        mode => '0600',
      }
    }

    # A bad, symbolic mode.
    class symbolic_file_mode {
      file { '/tmp/symbolic-mode':
        mode => 'ug=rw,o=rx',
      }
    }



## [puppet-lint non ERB template file name check](https://github.com/deanwilson/puppet-lint-non_erb_template_filename-check)
Extends puppet-lint to ensure all file names used in template functions
end with the string '.erb'.

This plugin is an extension of our local style guide and may not suit
your own code base. This sample would trigger the `puppet-lint` warning:

    class valid_template_filename {
      file { '/tmp/templated':
        content => template('mymodule/single_file.config'),
      }
    }

    # all template file names should end with ".erb"




## [puppet-lint world_writable_files check](https://github.com/deanwilson/puppet-lint-world_writable_files-check)
A puppet-lint extension that ensures file resources do not have a mode
that makes them world writable.

[![Build Status](https://travis-ci.org/deanwilson/puppet-lint-world_writable_files-check.svg?branch=master)](https://travis-ci.org/deanwilson/puppet-lint-world_writable_files-check)

On a *nix system a world writable file is one that anyone can write to.
This is often undesirable, especially in production, where who can
write to certain files should be limited and enabled with deliberation,
not by accident.

This plugin currently only checks octal file modes, the
[no_symbolic_file_modes](https://github.com/deanwilson/puppet-lint-no_symbolic_file_modes-check)
`puppet-lint` check ensure this isn't a problem for my code bases but it
might be a consideration for other peoples usages.



## [puppet-lint yumrepo_gpgcheck_enabled check](https://github.com/deanwilson/puppet-lint-yumrepo_gpgcheck_enabled-check)
A puppet-lint extension that ensures yumrepo resources have the gpgcheck
attribute and that it is enabled.

[![Build Status](https://travis-ci.org/deanwilson/puppet-lint-yumrepo_gpgcheck_enabled-check.svg?branch=master)](https://travis-ci.org/deanwilson/puppet-lint-yumrepo_gpgcheck_enabled-check)

The `gpgcheck` attribute indicates if `yum` should perform a GPG
signature check on packages. Having this disabled means you'll accept
any packages from your configured repo, not just those signed by the
packagers. While it's often more work to sign your own packages you should
at the very least enable it for all upstream yum repositories.



## [puppet-lint duplicate_class_parameters check](https://github.com/deanwilson/puppet-lint_duplicate_class_parameters-check)
A puppet-lint extension that ensures class parameter names are unique.

[![Build Status](https://travis-ci.org/deanwilson/puppet-lint_duplicate_class_parameters-check.svg?branch=master)](https://travis-ci.org/deanwilson/puppet-lint_duplicate_class_parameters-check)

Until Puppet 3.8.5 it was possible to have the same parameter name specified
multiple times in a class definition without error. This could cause
confusion as only the last value for that name was taken and it was decided in
[No error on duplicate parameters on classes and resources](https://tickets.puppetlabs.com/browse/PUP-5590)
that this behaviour should change and now return an error. This `puppet-lint`
plugin will help you catch those issues before you upgrade and suffer failures
in your puppet runs.

An exaggerated example of the previously valid, but awkward, behaviour can be found below -

    class file_resource(
      $duplicated = { 'a' => 1 },
      $duplicated = 'foo',
      $not_unique = 'bar',
      $not_unique = '2nd bar',
      $unique     = 'baz'
    ) {

      file { '/tmp/my-file':
        mode => '0600',
      }

    }

With this extension installed `puppet-lint` will return

    found duplicate parameter 'duplicated' in class 'file_resource'




## Other puppet-lint plugins

You can find information on other useful `puppet-lint` plugins in a few
other locations:

 * [puppet-lint.com/plugins](http://puppet-lint.com/plugins/) Some plugins mentioned on the puppet-lint homepage
 * [Vox Pupuli puppet-lint](https://voxpupuli.org/plugins/#puppet-lint) A collection of code
 donated and maintained by a group of individual puppet users.
 * [GitHub Puppet-lint search](https://github.com/search?utf8=%E2%9C%93&q=puppet-lint+check&type=Repositories&ref=searchresults)

### Author

[Dean Wilson](http://www.unixdaemon.net)

#### Notes

This readme is generated by the hacky `scripts/extract-readme.rb` script in this repo.

