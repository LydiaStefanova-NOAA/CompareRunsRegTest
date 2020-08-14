subroutine statsalone(dataA, maskA, ikind,countA,minA,maxA,meanA)
        use param
        real,dimension(ntile,nx,ny),intent(in)  :: dataA, maskA
        integer, intent(in)           :: ikind 
        integer,intent(out)           :: countA
        real,intent(out)              ::  minA, maxA,meanA
        countA = count(maskA.eq.ikind)
        minA   = minval(dataA,maskA.eq.ikind)
        maxA   = maxval(dataA,maskA.eq.ikind)
        meanA  = sum(dataA,maskA.eq.ikind)/countA
    end subroutine statsalone

    subroutine statscross(dataA, maskA,dataB,maskB,ikind,countAB,minAB,maxAB,meanAB,pnuAB,pndAB,rmsAB)
        use param
        real,dimension(ntile,nx,ny), intent(in)  :: dataA, maskA,dataB,maskB
        integer, intent(in)           :: ikind
        integer,intent(out)           :: countAB
        real,intent(out)              :: minAB, maxAB,meanAB,pnuAB,pndAB,rmsAB
        countAB = count((maskA.eq.ikind).and.(maskB.eq.ikind))
        minAB   = minval(dataA-dataB,((maskA.eq.ikind).and.(maskB.eq.ikind)))
        maxAB   = maxval(dataA-dataB,((maskA.eq.ikind).and.(maskB.eq.ikind)))
        meanAB  = sum(dataA-dataB,((maskA.eq.ikind).and.(maskB.eq.ikind)))/countAB
        rmsAB   = sqrt(sum((dataA-dataB)**2,((maskA.eq.ikind).and.(maskB.eq.ikind))) /countAB)
        pnuAB   = float(count(((dataA-dataB).gt.0).and.((maskA.eq.ikind).and.(maskB.eq.ikind))))/countAB
        pndAB   = float(count(((dataA-dataB).lt.0).and.((maskA.eq.ikind).and.(maskB.eq.ikind))))/countAB
    end subroutine statscross
