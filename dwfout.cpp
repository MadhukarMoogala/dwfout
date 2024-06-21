//////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2020 Autodesk, Inc.  All rights reserved.
//
//  Use of this software is subject to the terms of the Autodesk license 
//  agreement provided at the time of installation or download, or which 
//  otherwise accompanies this software in either electronic or hard copy form.   
//
//////////////////////////////////////////////////////////////////////////////
//
#if defined(_DEBUG) && !defined(AC_FULL_DEBUG)
#error _DEBUG should not be defined except in internal Adesk debug builds
#endif

#include <Windows.h>
#include <string.h>
#include <aced.h>
#include <dbents.h>
#include <dbsymtb.h>
#include <dbgroup.h>
#include <dbapserv.h>
#include "tchar.h"
#include <adscodes.h>
#include <acdocman.h>
#include "eoktest.h"
#include "AcDbLMgr.h"
#include "acaplmgr.h"
#include "rxregsvc.h"
#include <atlstr.h>


#define PUBLISH_DLL 	_T("AcPublish.crx")
#define PUBLISH_SVC     _T("AdskPublish")
typedef void (*EXPORT3DDWF)(bool, const ACHAR*, int);

void dwgoutcli(){
    TCHAR fileName[MAX_PATH] = _T("");
    int res = acedGetString(1, _T("\nPlease input the DWFX file name: "), fileName);
    if (res != RTNORM){
        return;
    } 
    bool bCancelled = false;
    int isFromCLI = 1;
    if (!acrxServiceIsRegistered(PUBLISH_SVC)) {
	if (!acrxDynamicLinker->loadModule(PUBLISH_DLL, false, true))
	return;
	}
    // Get the address of the export3dDWF service.
    
    EXPORT3DDWF pFunc = (EXPORT3DDWF) acrxDynamicLinker->
        getSymbolAddress(PUBLISH_SVC, "export3dDWF");
    if (pFunc == NULL) {
        assert(FALSE);
        return;
    }
    pFunc(bCancelled, fileName, isFromCLI);
}
void initApp()
{
    acedRegCmds->addCommand(_T("ASDK_MAKE_ENTS"),
                            _T("ASDK_MKENTS"),
                            _T("DWFOUTCLI"),
                            ACRX_CMD_MODAL,
                            dwgoutcli);
	
}

void unloadApp()
{
        acedRegCmds->removeGroup(_T("ASDK_MAKE_ENTS"));
}

extern "C" AcRx::AppRetCode acrxEntryPoint(AcRx::AppMsgCode msg, void* appId)
{
        switch (msg) {
        case AcRx::kInitAppMsg:
		       acrxDynamicLinker->unlockApplication(appId);
			   acrxDynamicLinker->registerAppMDIAware(appId);

                initApp();
                break;
        case AcRx::kUnloadAppMsg:
                unloadApp();
        }
        return AcRx::kRetOK;
}