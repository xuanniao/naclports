# Copyright 2014 The Native Client Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

from mock import patch, Mock

import common
from naclports import error
from naclports.configuration import Configuration


class TestConfiguration(common.NaclportsTest):
  def testDefaults(self):
    config = Configuration()
    self.assertEqual(config.toolchain, 'newlib')
    self.assertEqual(config.arch, 'x86_64')
    self.assertEqual(config.debug, False)
    self.assertEqual(config.config_name, 'release')
    self.assertEqual(config.libc, 'newlib')

  def testDefaultArch(self):
    # We default to x86_64 except in the special case where the build
    # machine is i686 hardware, in which case we default to i686.
    with patch('platform.machine', Mock(return_value='i686')):
      self.assertEqual(Configuration().arch, 'i686')
    with patch('platform.machine', Mock(return_value='dummy')):
      self.assertEqual(Configuration().arch, 'x86_64')

  def testEnvironmentVariables(self):
    with patch.dict('os.environ', {'NACL_ARCH': 'arm'}):
      self.assertEqual(Configuration().arch, 'arm')

    with patch.dict('os.environ', {'NACL_DEBUG': '1'}):
      self.assertEqual(Configuration().debug, True)

  def testDefaultToolchain(self):
    self.assertEqual(Configuration(arch='pnacl').toolchain, 'pnacl')
    self.assertEqual(Configuration(arch='arm').libc, 'newlib')

  def testDefaultLibc(self):
    self.assertEqual(Configuration(toolchain='pnacl').libc, 'newlib')
    self.assertEqual(Configuration(toolchain='newlib').libc, 'newlib')
    self.assertEqual(Configuration(toolchain='glibc').libc, 'glibc')
    self.assertEqual(Configuration(toolchain='bionic').libc, 'bionic')

  def testConfigStringForm(self):
    config = Configuration('arm', 'newlib', True)
    self.assertEqual(str(config), 'arm/newlib/debug')
    self.assertRegexpMatches(repr(config), '<Configuration .*>')

  def testConfigEquality(self):
    config1 = Configuration('arm', 'newlib', True)
    config2 = Configuration('arm', 'newlib', True)
    config3 = Configuration('arm', 'newlib', False)
    self.assertEqual(config1, config2)
    self.assertNotEqual(config1, config3)

  def testInvalidArch(self):
    expected_error = 'Invalid arch: not_arch'
    with self.assertRaisesRegexp(error.Error, expected_error):
      Configuration('not_arch')
