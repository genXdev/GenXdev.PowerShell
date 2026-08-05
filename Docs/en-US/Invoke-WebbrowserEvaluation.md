# Invoke-WebbrowserEvaluation

> **SubModule:** GenXdev.Webbrowser.Playwright | **Type:** Function | **Aliases:** `Eval`, `et`

## Synopsis

> Executes JavaScript code in a selected web browser tab.

## Description

Executes JavaScript code in a selected browser tab with support for async/await,
promises, and data synchronization between PowerShell and the browser context.
Can execute code from strings, files, or URLs.
This function provides comprehensive access to browser APIs including IndexedDB,
localStorage, sessionStorage, and other web platform features. It includes
built-in error handling, timeout management, and support for yielding multiple
results from generator functions.
The function uses Playwright for browser automation, which provides privileged
access that bypasses standard JavaScript security restrictions in the context
of the current page. This enables access to storage APIs, cross-origin
resources (within the same tab), and other browser features that would
normally be restricted in standard web contexts.
Key capabilities:
- Async/await and Promise support
- Generator functions with yield support
- Data synchronization via $Global:Data
- Privileged access to browser storage APIs
- Bypasses same-origin policy restrictions for current page storage
- IndexedDB enumeration and data extraction
- DOM manipulation and web API access
- Error handling and timeout management


## Syntax

```powershell
Invoke-WebbrowserEvaluation [[-Scripts] <Object[]>] [-ByReference <PSObject>] [-Chrome] [-Chromium] [-Edge] [-Firefox] [-Inspect] [-NoAutoSelectTab] [-Page <Object>] [-Webkit] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Scripts` | Object[] | ☐ | JavaScript code, file path or URL to execute |
| `-Inspect` | SwitchParameter | ☐ | Break in browser debugger before executing |
| `-NoAutoSelectTab` | SwitchParameter | ☐ | Prevent automatic tab selection |
| `-Edge` | SwitchParameter | ☐ | Use Microsoft Edge browser |
| `-Chrome` | SwitchParameter | ☐ | Use Google Chrome browser |
| `-Chromium` | SwitchParameter | ☐ | Use Microsoft Edge or Google Chrome, <br>depending on what the default browser is |
| `-Firefox` | SwitchParameter | ☐ | Use Firefox browser |
| `-Webkit` | SwitchParameter | ☐ | Use the Playwright-managed WebKit browser |
| `-Page` | Object | ☐ | Browser page object reference |
| `-ByReference` | PSObject | ☐ | Browser session reference object |

## Examples

### // Execute simple JavaScript Invoke-WebbrowserEvaluation "document.title = 'hello world'"

```powershell
// Execute simple JavaScript
Invoke-WebbrowserEvaluation "document.title = 'hello world'"
```

### PS> // Synchronizing data Select-WebbrowserTab -Force; $Global:Data = @{ files= (Get-ChildItem *.* -file | % FullName)}; [int] $number = Invoke-WebbrowserEvaluation "     document.body.innerHTML = JSON.stringify(data.files);     data.title = document.title;     return 123; "; Write-Host "     Document title : $($Global:Data.title)     return value   : $Number ";

```powershell
PS>
// Synchronizing data
Select-WebbrowserTab -Force;
$Global:Data = @{ files= (Get-ChildItem *.* -file | % FullName)};
[int] $number = Invoke-WebbrowserEvaluation "
    document.body.innerHTML = JSON.stringify(data.files);
    data.title = document.title;
    return 123;
";
Write-Host "
    Document title : $($Global:Data.title)
    return value   : $Number
";
```

### PS> Support for promises Select-WebbrowserTab -Force; Invoke-WebbrowserEvaluation "     let myList = [];     return new Promise((resolve) => {         let i = 0;         let a = setInterval(() => {             myList.push(++i);             if (i == 10) {                 clearInterval(a);                 resolve(myList);             }         }, 1000);     }); "

```powershell
PS>
Support for promises
Select-WebbrowserTab -Force;
Invoke-WebbrowserEvaluation "
    let myList = [];
    return new Promise((resolve) => {
        let i = 0;
        let a = setInterval(() => {
            myList.push(++i);
            if (i == 10) {
                clearInterval(a);
                resolve(myList);
            }
        }, 1000);
    });
"
```

### PS> // Support for promises and more // this function returns all rows of all tables/datastores of all databases of indexedDb in the selected tab // beware, not all websites use indexedDb, it could return an empty set Select-WebbrowserTab -Force; Set-WebbrowserTabLocation "https://www.youtube.com/" Start-Sleep 3 $AllIndexedDbData = Invoke-WebbrowserEvaluation "     // enumerate all indexedDB databases     for (let db of await indexedDB.databases()) {         // request to open database         let openRequest = await indexedDB.open(db.name);         // wait for eventhandlers to be called         await new Promise((resolve,reject) => {             openRequest.onsuccess = resolve;             openRequest.onerror = reject         });         // obtain reference         let openedDb = openRequest.result;         // initialize result         let result = { DatabaseName: db.name, Version: db.version, Stores: [] }         // itterate object store names         for (let i = 0; i < openedDb.objectStoreNames.length; i++) {             // reference             let storeName = openedDb.objectStoreNames[i];             // start readonly transaction             let tr = openedDb.transaction(storeName);             // get objectstore handle             let store = tr.objectStore(storeName);             // request all data             let getRequest = store.getAll();             // await result             await new Promise((resolve,reject) => {                 getRequest.onsuccess = resolve;                 getRequest.onerror = reject;             });             // add result             result.Stores.push({ StoreName: storeName, Data: getRequest.result});         }         // stream this database contents to the PowerShell pipeline, and continue         yield result;     } "; $AllIndexedDbData | Out-Host // SECURITY NOTE: This basic example works because the module uses Playwright // browser automation, which bypasses normal JavaScript security restrictions // in the current page context. Standard web pages cannot access IndexedDB from // other origins, but Playwright has the same privileges as the website itself. // See the enhanced example below for more details on security considerations.

```powershell
PS>
// Support for promises and more
// this function returns all rows of all tables/datastores of all databases of indexedDb in the selected tab
// beware, not all websites use indexedDb, it could return an empty set
Select-WebbrowserTab -Force;
Set-WebbrowserTabLocation "https://www.youtube.com/"
Start-Sleep 3
$AllIndexedDbData = Invoke-WebbrowserEvaluation "
    // enumerate all indexedDB databases
    for (let db of await indexedDB.databases()) {
        // request to open database
        let openRequest = await indexedDB.open(db.name);
        // wait for eventhandlers to be called
        await new Promise((resolve,reject) => {
            openRequest.onsuccess = resolve;
            openRequest.onerror = reject
        });
        // obtain reference
        let openedDb = openRequest.result;
        // initialize result
        let result = { DatabaseName: db.name, Version: db.version, Stores: [] }
        // itterate object store names
        for (let i = 0; i < openedDb.objectStoreNames.length; i++) {
            // reference
            let storeName = openedDb.objectStoreNames[i];
            // start readonly transaction
            let tr = openedDb.transaction(storeName);
            // get objectstore handle
            let store = tr.objectStore(storeName);
            // request all data
            let getRequest = store.getAll();
            // await result
            await new Promise((resolve,reject) => {
                getRequest.onsuccess = resolve;
                getRequest.onerror = reject;
            });
            // add result
            result.Stores.push({ StoreName: storeName, Data: getRequest.result});
        }
        // stream this database contents to the PowerShell pipeline, and continue
        yield result;
    }
";
$AllIndexedDbData | Out-Host
// SECURITY NOTE: This basic example works because the module uses Playwright
// browser automation, which bypasses normal JavaScript security restrictions
// in the current page context. Standard web pages cannot access IndexedDB from
// other origins, but Playwright has the same privileges as the website itself.
// See the enhanced example below for more details on security considerations.
```

### PS> // Enhanced IndexedDB enumeration with metadata and error handling // This enhanced approach provides more comprehensive IndexedDB data extraction including // database counts, error handling, and metadata. Unlike the basic example above, this // version handles security restrictions, provides detailed store information, and // includes record counts without necessarily retrieving all data. Select-WebbrowserTab -Force; Set-WebbrowserTabLocation "https://www.youtube.com/" Start-Sleep 3 $EnhancedIndexedDbData = Invoke-WebbrowserEvaluation "     // Enhanced IndexedDB enumeration with comprehensive error handling     let results = [];     for (let dbInfo of await indexedDB.databases()) {         try {             // Open database with timeout             let db = await new Promise((resolve, reject) => {                 let req = indexedDB.open(dbInfo.name);                 req.onsuccess = () => resolve(req.result);                 req.onerror = () => reject(req.error);                 setTimeout(() => reject(new Error('Database open timeout')), 5000);             });             let dbResult = {                 DatabaseName: dbInfo.name,                 Version: dbInfo.version,                 ObjectStoreCount: db.objectStoreNames.length,                 Stores: []             };             // Process each object store             for (let i = 0; i < db.objectStoreNames.length; i++) {                 let storeName = db.objectStoreNames[i];                 try {                     let transaction = db.transaction(storeName, 'readonly');                     let store = transaction.objectStore(storeName);                     // Get record count (faster than retrieving all data)                     let count = await new Promise((resolve, reject) => {                         let req = store.count();                         req.onsuccess = () => resolve(req.result);                         req.onerror = () => reject(req.error);                         setTimeout(() => reject(new Error('Count timeout')), 3000);                     });                     dbResult.Stores.push({                         StoreName: storeName,                         RecordCount: count,                         KeyPath: store.keyPath,                         AutoIncrement: store.autoIncrement,                         IndexNames: Array.from(store.indexNames)                     });                 } catch (storeError) {                     dbResult.Stores.push({                         StoreName: storeName,                         Error: storeError.message                     });                 }             }             results.push(dbResult);             db.close();         } catch (dbError) {             results.push({                 DatabaseName: dbInfo.name,                 Error: dbError.message             });         }     }     yield results; "; $EnhancedIndexedDbData | ConvertTo-Json -Depth 10 // Key differences from the basic example: // 1. Includes error handling for database access issues // 2. Provides metadata (KeyPath, AutoIncrement, IndexNames) // 3. Gets record counts without retrieving all data (more efficient) // 4. Handles timeout scenarios // 5. Returns structured information about database schema // 6. More suitable for large databases where retrieving all data would be slow // SECURITY CONSIDERATIONS FOR INDEXEDDB ACCESS: // Both examples work because this module uses Playwright browser automation, // which bypasses standard JavaScript security restrictions in the context // of the current page: // Standard JavaScript Limitations: // - Same-origin policy restricts access to IndexedDB from other origins // - Some databases may be hidden or protected by browser security features // - Cross-origin database access is typically blocked // - Service worker databases may have additional protection // How this example bypasses restrictions: // - Uses Playwright browser automation for privileged access // - Executes in the context of the actual page, not a sandboxed environment // - Has the same permissions as the website itself for its own storage // - Can access all databases created by the current origin/domain // Limitations: // - Cannot access databases from other origins/domains in the same browser // - Cannot access databases from other browser profiles or private browsing // - Some browser extensions may create isolated storage not accessible via JavaScript // Alternative Approaches for Maximum Access: // - Use GenXdev.Webbrowser with multiple tabs from different origins // - Combine with file system access to browser profile directories (when possible) // - Use browser automation to navigate between different domains

```powershell
PS>
// Enhanced IndexedDB enumeration with metadata and error handling
// This enhanced approach provides more comprehensive IndexedDB data extraction including
// database counts, error handling, and metadata. Unlike the basic example above, this
// version handles security restrictions, provides detailed store information, and
// includes record counts without necessarily retrieving all data.
Select-WebbrowserTab -Force;
Set-WebbrowserTabLocation "https://www.youtube.com/"
Start-Sleep 3
$EnhancedIndexedDbData = Invoke-WebbrowserEvaluation "
    // Enhanced IndexedDB enumeration with comprehensive error handling
    let results = [];
    for (let dbInfo of await indexedDB.databases()) {
        try {
            // Open database with timeout
            let db = await new Promise((resolve, reject) => {
                let req = indexedDB.open(dbInfo.name);
                req.onsuccess = () => resolve(req.result);
                req.onerror = () => reject(req.error);
                setTimeout(() => reject(new Error('Database open timeout')), 5000);
            });
            let dbResult = {
                DatabaseName: dbInfo.name,
                Version: dbInfo.version,
                ObjectStoreCount: db.objectStoreNames.length,
                Stores: []
            };
            // Process each object store
            for (let i = 0; i < db.objectStoreNames.length; i++) {
                let storeName = db.objectStoreNames[i];
                try {
                    let transaction = db.transaction(storeName, 'readonly');
                    let store = transaction.objectStore(storeName);
                    // Get record count (faster than retrieving all data)
                    let count = await new Promise((resolve, reject) => {
                        let req = store.count();
                        req.onsuccess = () => resolve(req.result);
                        req.onerror = () => reject(req.error);
                        setTimeout(() => reject(new Error('Count timeout')), 3000);
                    });
                    dbResult.Stores.push({
                        StoreName: storeName,
                        RecordCount: count,
                        KeyPath: store.keyPath,
                        AutoIncrement: store.autoIncrement,
                        IndexNames: Array.from(store.indexNames)
                    });
                } catch (storeError) {
                    dbResult.Stores.push({
                        StoreName: storeName,
                        Error: storeError.message
                    });
                }
            }
            results.push(dbResult);
            db.close();
        } catch (dbError) {
            results.push({
                DatabaseName: dbInfo.name,
                Error: dbError.message
            });
        }
    }
    yield results;
";
$EnhancedIndexedDbData | ConvertTo-Json -Depth 10
// Key differences from the basic example:
// 1. Includes error handling for database access issues
// 2. Provides metadata (KeyPath, AutoIncrement, IndexNames)
// 3. Gets record counts without retrieving all data (more efficient)
// 4. Handles timeout scenarios
// 5. Returns structured information about database schema
// 6. More suitable for large databases where retrieving all data would be slow
// SECURITY CONSIDERATIONS FOR INDEXEDDB ACCESS:
// Both examples work because this module uses Playwright browser automation,
// which bypasses standard JavaScript security restrictions in the context
// of the current page:
// Standard JavaScript Limitations:
// - Same-origin policy restricts access to IndexedDB from other origins
// - Some databases may be hidden or protected by browser security features
// - Cross-origin database access is typically blocked
// - Service worker databases may have additional protection
// How this example bypasses restrictions:
// - Uses Playwright browser automation for privileged access
// - Executes in the context of the actual page, not a sandboxed environment
// - Has the same permissions as the website itself for its own storage
// - Can access all databases created by the current origin/domain
// Limitations:
// - Cannot access databases from other origins/domains in the same browser
// - Cannot access databases from other browser profiles or private browsing
// - Some browser extensions may create isolated storage not accessible via JavaScript
// Alternative Approaches for Maximum Access:
// - Use GenXdev.Webbrowser with multiple tabs from different origins
// - Combine with file system access to browser profile directories (when possible)
// - Use browser automation to navigate between different domains
```

### PS> Support for yielded pipeline results Select-WebbrowserTab -Force; Invoke-WebbrowserEvaluation "     for (let i = 0; i < 10; i++) {         await (new Promise((resolve) => setTimeout(resolve, 1000)));         yield i;     } ";

```powershell
PS>
Support for yielded pipeline results
Select-WebbrowserTab -Force;
Invoke-WebbrowserEvaluation "
    for (let i = 0; i < 10; i++) {
        await (new Promise((resolve) => setTimeout(resolve, 1000)));
        yield i;
    }
";
```

### PS> Get-ChildItem *.js | Invoke-WebbrowserEvaluation -Edge

```powershell
PS> Get-ChildItem *.js | Invoke-WebbrowserEvaluation -Edge
```

### PS> ls *.js | et -e

```powershell
PS> ls *.js | et -e
```

## Parameter Details

### `-Scripts <Object[]>`

> JavaScript code, file path or URL to execute

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `FullName` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Inspect`

> Break in browser debugger before executing

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoAutoSelectTab`

> Prevent automatic tab selection

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Edge`

> Use Microsoft Edge browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `e` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Chrome`

> Use Google Chrome browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ch` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Chromium`

> Use Microsoft Edge or Google Chrome,  depending on what the default browser is

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `c` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Firefox`

> Use Firefox browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ff` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Webkit`

> Use the Playwright-managed WebKit browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `wk` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Page <Object>`

> Browser page object reference

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ByReference <PSObject>`

> Browser session reference object

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Connect-PlaywrightViaDebuggingPort](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Connect-PlaywrightViaDebuggingPort.md)
- [Get-PlaywrightProfileDirectory](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightProfileDirectory.md)
- [Get-PlaywrightSessionReference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightSessionReference.md)
- [Get-WebbrowserTabDomNodes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WebbrowserTabDomNodes.md)
- [Open-PlayWrightBrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-PlayWrightBrowser.md)
- [Resume-WebbrowserTabVideo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Resume-WebbrowserTabVideo.md)
- [Select-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Select-WebbrowserTab.md)
- [Set-BrowserVideoFullscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-BrowserVideoFullscreen.md)
- [Set-WebbrowserTabLocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WebbrowserTabLocation.md)
- [Stop-WebbrowserVideos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-WebbrowserVideos.md)
- [Unprotect-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unprotect-WebbrowserTab.md)
