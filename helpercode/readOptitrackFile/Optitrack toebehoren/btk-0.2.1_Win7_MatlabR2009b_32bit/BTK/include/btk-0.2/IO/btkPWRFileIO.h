/* 
 * The Biomechanical ToolKit
 * Copyright (c) 2009-2013, Arnaud Barré
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 *     * Redistributions of source code must retain the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer.
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials
 *       provided with the distribution.
 *     * Neither the name(s) of the copyright holders nor the names
 *       of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written
 *       permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef __btkPWRFileIO_h
#define __btkPWRFileIO_h

#include "btkAcquisitionFileIO.h"
#include "btkException.h"

namespace btk
{
  class PWRFileIOException : public Exception
  {
  public:
    explicit PWRFileIOException(const std::string& msg)
    : Exception(msg)
    {};
      
    virtual ~PWRFileIOException() throw() {};
  };
  
  class PWRFileIO : public AcquisitionFileIO
  {
    BTK_FILE_IO_SUPPORTED_EXTENSIONS("PWR");
    BTK_FILE_IO_ONLY_READ_OPERATION;
    
  public:
    typedef SharedPtr<PWRFileIO> Pointer;
    typedef SharedPtr<const PWRFileIO> ConstPointer;
    
    static Pointer New() {return Pointer(new PWRFileIO());};
    
    // ~PWRFileIO(); // Implicit.
    
    BTK_IO_EXPORT virtual bool CanReadFile(const std::string& filename);
    BTK_IO_EXPORT virtual void Read(const std::string& filename, Acquisition::Pointer output);
    
  protected:
    BTK_IO_EXPORT PWRFileIO();
    
  private:
    PWRFileIO(const PWRFileIO& ); // Not implemented.
    PWRFileIO& operator=(const PWRFileIO& ); // Not implemented. 
   };
};

#endif // __btkPWRFileIO_h
