#include "mingw32_wrapper.h"
#include <stdbool.h>

char *realpath(const char *path, char resolved_path[PATH_MAX])
{
  char *return_path;
  
  printf("realpath: %s\n", path);
  
  return_path = _fullpath(resolved_path, path, PATH_MAX);
  
  printf("returnpath: %s\n", return_path);
  
  return return_path;
/**
  char *return_path = 0;

  if (path) //Else EINVAL
  {
    if (resolved_path)
    {
      return_path = resolved_path;
    }
    else
    {
      //Non standard extension that glibc uses
      return_path = malloc(PATH_MAX); 
    }

    if (return_path) //Else EINVAL
    {
      //This is a Win32 API function similar to what realpath() is supposed to do
      size_t size = GetFullPathNameA(path, PATH_MAX, return_path, 0);

      //GetFullPathNameA() returns a size larger than buffer if buffer is too small
      if (size > PATH_MAX)
      {
        if (return_path != resolved_path) //Malloc'd buffer - Unstandard extension retry
        {
          size_t new_size;
          
          free(return_path);
          return_path = malloc(size);

          if (return_path)
          {
            new_size = GetFullPathNameA(path, size, return_path, 0); //Try again

            if (new_size > size) //If it's still too large, we have a problem, don't try again
            {
              free(return_path);
              return_path = 0;
              errno = ENAMETOOLONG;
            }
            else
            {
              size = new_size;
            }
          }
          else
          {
            //I wasn't sure what to return here, but the standard does say to return EINVAL
            //if resolved_path is null, and in this case we couldn't malloc large enough buffer
            errno = EINVAL;
          }  
        }
        else //resolved_path buffer isn't big enough
        {
          return_path = 0;
          errno = ENAMETOOLONG;
        }
      }

      //GetFullPathNameA() returns 0 if some path resolve problem occured
      if (!size) 
      {
        if (return_path != resolved_path) //Malloc'd buffer
        {
          free(return_path);
        }
        
        return_path = 0;

        //Convert MS errors into standard errors
        switch (GetLastError())
        {
          case ERROR_FILE_NOT_FOUND:
            errno = ENOENT;
            break;

          case ERROR_PATH_NOT_FOUND: case ERROR_INVALID_DRIVE:
            errno = ENOTDIR;
            break;

          case ERROR_ACCESS_DENIED:
            errno = EACCES;
            break;
          
          default: //Unknown Error
            errno = EIO;
            break;
        }
      }

      //If we get to here with a valid return_path, we're still doing good
      if (return_path)
      {
        struct stat stat_buffer;

        //Make sure path exists, stat() returns 0 on success
        if (stat(return_path, &stat_buffer)) 
        {
          if (return_path != resolved_path)
          {
            free(return_path);
          }
        
          return_path = 0;
          //stat() will set the correct errno for us
        }
        //else we succeeded!
      }
    }
    else
    {
      errno = EINVAL;
    }
  }
  else
  {
    errno = EINVAL;
  }
  
   return return_path;
   */
}
  
long getpagesize (void) {
    static long g_pagesize = 0;
    if (! g_pagesize) {
      SYSTEM_INFO system_info;
      GetSystemInfo (&system_info);
      g_pagesize = system_info.dwPageSize;
     }
     return g_pagesize;
  }
  
/**
int pread(unsigned int fd, char *buf, size_t count, int offset)
{
  if (_lseek(fd, offset, SEEK_SET) != offset) {
    return -1;
  }
  return read(fd, buf, count);
}
*/

// https://gist.github.com/przemoc/fbf2bfb11af0d9cd58726c200e4d133e
ssize_t pread(int fd, void *buf, size_t count, long long offset)
{
  printf("pread(): fd=%d, count=%d, offset=%d\n", fd, count, offset);

  OVERLAPPED o = {0,0,0,0,0};
  HANDLE fh = (HANDLE)_get_osfhandle(fd);
  uint64_t off = offset;
  DWORD bytes;
  BOOL ret;

  if (fh == INVALID_HANDLE_VALUE) {
    errno = EBADF;
    return -1;
  }

  o.Offset = off & 0xffffffff;
  o.OffsetHigh = (off >> 32) & 0xffffffff;

  ret = ReadFile(fh, buf, (DWORD)count, &bytes, &o);
  if (!ret) {
    errno = EIO;
    return -1;
  }

  return (ssize_t)bytes;
}

ssize_t pwrite(int fd, const void *buf, size_t count, long long offset)
{
  printf("pwrite(): fd=%d, count=%d, offset=%d\n", fd, count, offset);
  
  OVERLAPPED o = {0,0,0,0,0};
  HANDLE fh = (HANDLE)_get_osfhandle(fd);
  uint64_t off = offset;
  DWORD bytes;
  BOOL ret;

  if (fh == INVALID_HANDLE_VALUE) {
    errno = EBADF;
    return -1;
  }

  o.Offset = off & 0xffffffff;
  o.OffsetHigh = (off >> 32) & 0xffffffff;

  ret = WriteFile(fh, buf, (DWORD)count, &bytes, &o);
  if (!ret) {
    errno = EIO;
    return -1;
  }

  return (ssize_t)bytes;
}
